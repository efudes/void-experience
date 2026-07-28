#!/bin/sh
set -eu

if [ -n "${1-}" ]; then
    backup_id=$1
elif [ -f "$HOME/.config/void-experience-backup" ]; then
    backup_id=$(cat "$HOME/.config/void-experience-backup")
else
    echo "Usage: ./scripts/rollback.sh <backup-id>" >&2
    exit 2
fi

case "$backup_id" in
    *[!0-9-]*|'') echo "Invalid backup identifier: $backup_id" >&2; exit 2 ;;
esac

backup_root="$HOME/desktop-backups/void-experience/$backup_id"
present_file="$backup_root/PRESENT.txt"
[ -f "$present_file" ] || {
    echo "Portable backup not found: $backup_root" >&2
    exit 1
}

case "${XDG_CURRENT_DESKTOP-}" in
    *XFCE*) ;;
    *) echo "Refusing live rollback outside an XFCE session." >&2; exit 1 ;;
esac

recovery_id=$(date +%Y%m%d-%H%M%S)
recovery_root="$backup_root/rollback-displaced-$recovery_id"
mkdir -p "$recovery_root"

displace_path() {
    target_path=$1
    [ -e "$target_path" ] || return 0
    relative_path=${target_path#"$HOME/"}
    mkdir -p "$recovery_root/$(dirname -- "$relative_path")"
    mv "$target_path" "$recovery_root/$relative_path"
}

# Whole user-local configuration trees are moved into a recovery snapshot, not
# deleted. This makes rollback exact while preserving changes made after install.
for target in \
    "$HOME/.config/xfce4" \
    "$HOME/.config/picom" \
    "$HOME/.config/rofi" \
    "$HOME/.config/autostart" \
    "$HOME/.config/kitty" \
    "$HOME/.config/Thunar" \
    "$HOME/.config/mimeapps.list" \
    "$HOME/.local/share/applications/mimeapps.list" \
    "$HOME/.themes/Void-Experience"; do
    displace_path "$target"
done

while IFS= read -r relative_path; do
    [ -n "$relative_path" ] || continue
    source_path="$backup_root/$relative_path"
    [ -e "$source_path" ] || continue
    mkdir -p "$HOME/$(dirname -- "$relative_path")"
    cp -a "$source_path" "$HOME/$relative_path"
done <"$present_file"

for project_file in \
    "$HOME/.local/bin/void-experience-picom" \
    "$HOME/.local/bin/void-panel-watch" \
    "$HOME/.local/bin/void-layout" \
    "$HOME/.local/bin/void-network-indicator" \
    "$HOME/.local/bin/void-preview" \
    "$HOME/.local/bin/void-toggle-desktop" \
    "$HOME/.local/lib/void-experience/configure-panels" \
    "$HOME/.local/share/void-experience/genmon-network.rc" \
    "$HOME/.local/share/xfce4/xkb/flags/us.svg" \
    "$HOME/.local/share/xfce4/xkb/flags/ru.svg" \
    "$HOME/.local/share/icons/hicolor/scalable/apps/void-experience-menu.svg"; do
    [ -e "$project_file" ] && displace_path "$project_file"
done

rm -f -- "$HOME/.config/void-experience-backup"

echo "Baseline $backup_id restored."
echo "Displaced post-install files are recoverable from: $recovery_root"
echo "Log out and back into XFCE to complete rollback."
echo "Debian packages were intentionally retained."
