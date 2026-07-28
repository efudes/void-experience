#!/bin/sh
set -eu

backup_id=${1:-$(date +%Y%m%d-%H%M%S)}
backup_root="$HOME/desktop-backups/void-experience/$backup_id"

case "$backup_id" in
    *[!0-9-]*|'') echo "Invalid backup identifier: $backup_id" >&2; exit 2 ;;
esac

[ ! -e "$backup_root" ] || {
    echo "Backup already exists: $backup_root" >&2
    exit 1
}

mkdir -p "$backup_root"
: >"$backup_root/PRESENT.txt"

copy_path() {
    source_path=$1
    [ -e "$source_path" ] || return 0
    relative_path=${source_path#"$HOME/"}
    printf '%s\n' "$relative_path" >>"$backup_root/PRESENT.txt"
    mkdir -p "$backup_root/$(dirname -- "$relative_path")"
    cp -a "$source_path" "$backup_root/$relative_path"
}

for path in \
    "$HOME/.config/xfce4" \
    "$HOME/.config/picom" \
    "$HOME/.config/rofi" \
    "$HOME/.config/autostart" \
    "$HOME/.config/kitty" \
    "$HOME/.config/Thunar" \
    "$HOME/.config/mimeapps.list" \
    "$HOME/.local/share/applications/mimeapps.list" \
    "$HOME/.themes/Void-Experience"; do
    copy_path "$path"
done

if command -v xfce4-panel-profiles >/dev/null 2>&1; then
    mkdir -p "$backup_root/panel-profile"
    xfce4-panel-profiles save \
        "$backup_root/panel-profile/xfce-panel.tar.bz2" 2>/dev/null || true
fi

cat >"$backup_root/MANIFEST.txt" <<EOF
Void Experience pre-install backup
Created: $(date --iso-8601=seconds)
Host: $(hostname)
User: $(id -un)
Desktop: ${XDG_CURRENT_DESKTOP-}
Session: ${XDG_SESSION_TYPE-}
EOF

echo "Backup created: $backup_root"
