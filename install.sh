#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
packages='xfce4 xfce4-goodies arc-theme xfce4-panel-profiles xfce4-whiskermenu-plugin xfce4-pulseaudio-plugin xfce4-xkb-plugin xfce4-genmon-plugin xfce4-screensaver picom rofi wmctrl xdotool kitty thunar tumbler papirus-icon-theme bibata-cursor-theme network-manager-gnome celluloid gnome-sushi ffmpeg libmpv2 x11-utils x11-xserver-utils libnotify-bin'

usage() {
    cat <<'EOF'
Usage: ./install.sh [--skip-packages] [--shared-media-defaults] [--dry-run]

Run this script from an XFCE/Xorg session on Debian 13. It creates a complete
timestamped backup before changing user configuration. GNOME, GDM, dconf and
GNOME Shell are never modified.

--shared-media-defaults opts into making Celluloid the freedesktop default for
audio/video. That MIME choice is shared by XFCE and GNOME.
EOF
}

skip_packages=false
shared_media_defaults=false
dry_run=false
for argument in "$@"; do
    case "$argument" in
        --skip-packages) skip_packages=true ;;
        --shared-media-defaults) shared_media_defaults=true ;;
        --dry-run) dry_run=true ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *)
        echo "Run Void Experience after logging into an XFCE/Xorg session." >&2
        echo "Nothing was changed." >&2
        exit 1
        ;;
esac

if [ ! -r /etc/os-release ] ||
    ! grep -q '^ID=debian$' /etc/os-release ||
    ! grep -Eq '^(VERSION_ID=\"?13\"?|VERSION_CODENAME=trixie)$' /etc/os-release; then
    echo "This release is tested only on Debian 13 (trixie)." >&2
    exit 1
fi

if "$dry_run"; then
    echo "Dry run: prerequisites and session are compatible."
    echo "Packages: $packages"
    echo "Backup root: \$HOME/desktop-backups/void-experience/<timestamp>"
    echo "Apply command: $project_dir/scripts/apply.sh --all"
    exit 0
fi

if ! "$skip_packages"; then
    echo
    echo "Void Experience needs Debian packages for XFCE, Picom, Rofi,"
    echo "window layouts, media preview, themes and panel plugins."
    echo "The following privileged commands update APT metadata and install them:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y $packages"
    printf "Continue with package installation? [y/N] "
    read -r answer
    case "$answer" in
        y|Y|yes|YES)
            sudo apt-get update
            # shellcheck disable=SC2086
            sudo apt-get install -y $packages
            ;;
        *)
            echo "Package installation skipped. Re-run with --skip-packages" >&2
            echo "only when all requirements are already installed." >&2
            exit 1
            ;;
    esac
fi

backup_id=$(date +%Y%m%d-%H%M%S)
"$project_dir/scripts/backup.sh" "$backup_id"
if "$shared_media_defaults"; then
    VOID_EXPERIENCE_SHARED_MEDIA_DEFAULTS=1 \
        "$project_dir/scripts/apply.sh" --all
else
    "$project_dir/scripts/apply.sh" --all
fi

printf '%s\n' "$backup_id" >"$HOME/.config/void-experience-backup"

echo
echo "Void Experience installed successfully."
echo "Backup: $HOME/desktop-backups/void-experience/$backup_id"
echo "Validate with: $project_dir/scripts/check.sh"
echo "Rollback with: $project_dir/scripts/rollback.sh $backup_id"
