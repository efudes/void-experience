#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
profile_dir="$HOME/.config/void-experience/zsh"
source_line='source "$HOME/.config/void-experience/zsh/void-experience.zsh"'
begin_marker='# >>> Void Experience Zsh >>>'
end_marker='# <<< Void Experience Zsh <<<'
dry_run=false
make_default=false
backup_id=

for argument in "$@"; do
    case "$argument" in
        --dry-run) dry_run=true ;;
        --make-default) make_default=true ;;
        --backup-id=*) backup_id=${argument#--backup-id=} ;;
        -h|--help)
            echo "Usage: scripts/install-void-zsh.sh --backup-id=ID [--dry-run] [--make-default]"
            exit 0
            ;;
        *) echo "Unknown argument: $argument" >&2; exit 2 ;;
    esac
done

if "$dry_run"; then
    echo "Would install the Void Zsh profile in: $profile_dir"
    echo "Would append one managed source block to: $HOME/.zshrc"
    "$make_default" && echo "Would request Zsh as the login shell."
    exit 0
fi

case "$backup_id" in
    *[!0-9-]*|'')
        echo "A valid --backup-id is required before modifying shell files." >&2
        exit 2
        ;;
esac
backup_root="$HOME/desktop-backups/void-experience/$backup_id"
[ -f "$backup_root/PRESENT.txt" ] || {
    echo "Backup is missing: $backup_root" >&2
    exit 1
}

command -v zsh >/dev/null 2>&1 || {
    echo "zsh is not installed; run the package selector first." >&2
    exit 1
}

mkdir -p "$profile_dir"
install -m 0644 "$project_dir/configs/zsh/void-experience.zsh" \
    "$profile_dir/void-experience.zsh"
install -m 0644 "$project_dir/configs/zsh/starship.toml" \
    "$profile_dir/starship.toml"

font_source="$project_dir/assets/fonts/JetBrainsMonoNerdFont-Regular.ttf"
font_target="$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf"
if [ -f "$font_source" ]; then
    install -Dm0644 "$font_source" "$font_target"
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
fi

mkdir -p "$HOME/.config/kitty"
install -m 0644 "$project_dir/configs/kitty/void-zsh-font.conf" \
    "$HOME/.config/kitty/void-zsh-font.conf"
touch "$HOME/.config/kitty/kitty.conf"
if ! grep -Fqx 'include void-zsh-font.conf' "$HOME/.config/kitty/kitty.conf"; then
    printf '\ninclude void-zsh-font.conf\n' >>"$HOME/.config/kitty/kitty.conf"
fi

touch "$HOME/.zshrc"
if ! grep -Fqx "$begin_marker" "$HOME/.zshrc"; then
    {
        printf '\n%s\n' "$begin_marker"
        printf '%s\n' "$source_line"
        printf '%s\n' "$end_marker"
    } >>"$HOME/.zshrc"
fi

if "$make_default"; then
    zsh_path=$(command -v zsh)
    current_shell=$(getent passwd "$(id -un)" | cut -d: -f7)
    if [ "$current_shell" != "$zsh_path" ]; then
        chsh -s "$zsh_path"
    fi
fi

echo "Void Zsh profile installed. Start a new terminal or run: exec zsh"
