#!/bin/sh
set -eu

core_packages='xfce4 arc-theme xfce4-panel-profiles xfce4-whiskermenu-plugin xfce4-pulseaudio-plugin xfce4-xkb-plugin xfce4-genmon-plugin xfce4-screensaver xfce4-screenshooter xfce4-clipman flameshot picom rofi wmctrl xdotool kitty thunar tumbler papirus-icon-theme bibata-cursor-theme network-manager network-manager-gnome celluloid gnome-sushi ffmpeg libmpv2 x11-utils x11-xserver-utils libnotify-bin fonts-noto-core fontconfig xdg-user-dirs xdg-utils util-linux procps libgtk-3-bin whiptail bash gcc libc6-dev'
selected=none
interactive=true
dry_run=false
selection_requested=false

usage() {
    cat <<'EOF'
Usage: scripts/install-packages.sh [--select] [--extras=LIST] [--dry-run]

The Debian core is always installed. LIST is a comma-separated selection of:
flatpak,steam,lutris,discord,portproton,ani-cli,void-zsh,codex-bypass,cava,ncdu,duf,
du-dust,lazygit,broot,glow,none

Without --extras the script opens a terminal checklist. Gaming and communication
apps are installed per-user from Flathub only after explicit selection.
EOF
}

for argument in "$@"; do
    case "$argument" in
        --select) interactive=true; selection_requested=true ;;
        --extras=*) selected=${argument#--extras=}; interactive=false; selection_requested=true ;;
        --dry-run) dry_run=true ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

if "$dry_run" && ! "$selection_requested"; then
    interactive=false
fi

validate_selection() {
    old_ifs=$IFS
    IFS=,
    for item in $selected; do
        case "$item" in
            flatpak|steam|lutris|discord|portproton|ani-cli|void-zsh|\
            codex-bypass|cava|ncdu|duf|du-dust|lazygit|broot|glow|none|'') ;;
            *) echo "Unknown optional component: $item" >&2; exit 2 ;;
        esac
    done
    IFS=$old_ifs
}

if "$interactive"; then
    if command -v whiptail >/dev/null 2>&1; then
        set +e
        selected=$(
            whiptail --title "Void Experience — optional software" \
                --checklist \
                "Space toggles a component. Core XFCE and MP3/video support are mandatory." \
                28 84 18 \
                flatpak "Flatpak + Flathub only" OFF \
                steam "Steam (community Flatpak, unverified)" OFF \
                lutris "Lutris (Flathub)" OFF \
                discord "Discord (Flathub, proprietary)" OFF \
                portproton "PortProton (Flathub, x86_64)" OFF \
                ani-cli "ani-cli (terminal anime browser/player)" OFF \
                void-zsh "Void Zsh (portable terminal profile)" OFF \
                codex-bypass "crb: Codex resume without sandbox (DANGEROUS)" OFF \
                cava "CAVA (terminal audio visualizer)" OFF \
                ncdu "ncdu (interactive disk usage)" OFF \
                duf "duf (filesystem overview)" OFF \
                du-dust "dust (visual directory sizes)" OFF \
                lazygit "lazygit (terminal Git UI)" OFF \
                broot "broot (interactive file tree)" OFF \
                glow "Glow (terminal Markdown reader)" OFF \
                3>&1 1>&2 2>&3
        )
        status=$?
        set -e
        [ "$status" -eq 0 ] || {
            echo "Package selection cancelled; nothing was installed." >&2
            exit 1
        }
        selected=$(printf '%s' "$selected" | tr -d '"' | tr ' ' ',')
    else
        echo "whiptail is unavailable; using safe defaults: $selected"
        echo "Use --extras=LIST for an explicit non-interactive selection."
    fi
fi

validate_selection
[ -z "${VOID_EXPERIENCE_SELECTION_FILE-}" ] ||
    printf '%s\n' "$selected" >"$VOID_EXPERIENCE_SELECTION_FILE"
apt_packages=$core_packages
flatpak_apps=
need_flatpak=false

has_selection() {
    case ",$selected," in
        *,"$1",*) return 0 ;;
        *) return 1 ;;
    esac
}

if has_selection codex-bypass && ! has_selection void-zsh; then
    echo "codex-bypass requires the void-zsh component." >&2
    exit 2
fi

for mapping in \
    'steam:com.valvesoftware.Steam' \
    'lutris:net.lutris.Lutris' \
    'discord:com.discordapp.Discord' \
    'portproton:ru.linux_gaming.PortProton'; do
    tag=${mapping%%:*}
    app_id=${mapping#*:}
    if has_selection "$tag"; then
        need_flatpak=true
        flatpak_apps="$flatpak_apps $app_id"
    fi
done
has_selection flatpak && need_flatpak=true
"$need_flatpak" && apt_packages="$apt_packages flatpak"
has_selection ani-cli && apt_packages="$apt_packages ani-cli"
for optional_apt in cava ncdu duf du-dust lazygit broot glow; do
    has_selection "$optional_apt" &&
        apt_packages="$apt_packages $optional_apt"
done
if has_selection void-zsh; then
    apt_packages="$apt_packages zsh starship zoxide eza bat ripgrep fd-find fastfetch btop fzf zsh-autosuggestions zsh-syntax-highlighting fonts-jetbrains-mono"
fi
architecture=$(dpkg --print-architecture)
if [ "$architecture" != amd64 ] &&
    { has_selection steam || has_selection portproton; }; then
    echo "Steam and PortProton selections require amd64; detected $architecture." >&2
    exit 1
fi

echo "Mandatory Debian core (includes MP3/video support):"
echo "  $core_packages"
echo "Selected optional components: ${selected:-none}"
echo "APT command:"
echo "  sudo apt-get update"
echo "  sudo apt-get install -y $apt_packages"
if "$need_flatpak"; then
    echo "Flathub command (per-user remote):"
    echo "  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
fi
if [ -n "$flatpak_apps" ]; then
    echo "Selected Flatpak apps:"
    echo "  $flatpak_apps"
fi

"$dry_run" && exit 0

printf "Install exactly this package selection? [y/N] "
read -r answer
case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Package installation cancelled." >&2; exit 1 ;;
esac

if has_selection void-zsh; then
    echo
    echo "Void Zsh will add a managed source block to ~/.zshrc."
    echo "Existing shell files must be backed up by install.sh before the profile is applied."
    printf "Type INSTALL VOID ZSH to confirm the optional shell profile: "
    read -r zsh_answer
    [ "$zsh_answer" = "INSTALL VOID ZSH" ] || {
        echo "Void Zsh confirmation failed; package installation cancelled." >&2
        exit 1
    }
fi
if has_selection codex-bypass; then
    echo
    echo "WARNING: crb disables Codex approval prompts and sandbox isolation."
    echo "A resumed session can execute commands with your user permissions."
    printf "Type ENABLE CODEX BYPASS to add this alias: "
    read -r bypass_answer
    [ "$bypass_answer" = "ENABLE CODEX BYPASS" ] || {
        echo "Codex bypass confirmation failed; package installation cancelled." >&2
        exit 1
    }
fi

sudo apt-get update
# shellcheck disable=SC2086
sudo apt-get install -y $apt_packages

if "$need_flatpak"; then
    flatpak remote-add --user --if-not-exists \
        flathub https://flathub.org/repo/flathub.flatpakrepo
fi
if [ -n "$flatpak_apps" ]; then
    # shellcheck disable=SC2086
    flatpak install --user -y flathub $flatpak_apps
fi
