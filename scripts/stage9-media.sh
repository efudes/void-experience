#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
thunar_dir="$HOME/.config/Thunar"
uca_file="$thunar_dir/uca.xml"
accels_file="$thunar_dir/accels.scm"
action_file="$project_dir/configs/xfce4/thunar-void-preview-action.xml"
accel_path='<Actions>/ThunarActions/uca-action-void-experience-preview'

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *)
        echo "Refusing media integration outside XFCE/X11." >&2
        exit 1
        ;;
esac

for command_name in celluloid sushi thunar; do
    command -v "$command_name" >/dev/null 2>&1 || {
        echo "Missing required command: $command_name" >&2
        exit 1
    }
done

mkdir -p "$thunar_dir" "$HOME/.local/bin"
install -m 0755 "$project_dir/scripts/void-preview" \
    "$HOME/.local/bin/void-preview"

if [ ! -f "$uca_file" ]; then
    printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' \
        '<actions>' '</actions>' >"$uca_file"
fi
touch "$accels_file"

if ! grep -Fq '<unique-id>void-experience-preview</unique-id>' "$uca_file"; then
    tmp_uca=$(mktemp)
    awk -v action_file="$action_file" '
        /<\/actions>/ {
            while ((getline line < action_file) > 0)
                print line
            close(action_file)
        }
        { print }
    ' "$uca_file" >"$tmp_uca"
    chmod --reference="$uca_file" "$tmp_uca"
    mv "$tmp_uca" "$uca_file"
fi

if ! grep -Fq "$accel_path" "$accels_file"; then
    printf '\n(gtk_accel_path "%s" "space")\n' "$accel_path" >>"$accels_file"
fi

if [ "${VOID_EXPERIENCE_SHARED_MEDIA_DEFAULTS-0}" = 1 ]; then
    celluloid_desktop='io.github.celluloid_player.Celluloid.desktop'
    celluloid_file="/usr/share/applications/$celluloid_desktop"
    [ -f "$celluloid_file" ] || {
        echo "Celluloid desktop entry is missing: $celluloid_file" >&2
        exit 1
    }
    # This opt-in is shared across desktop sessions by freedesktop MIME design.
    sed -n 's/^MimeType=//p' "$celluloid_file" |
        tr ';' '\n' |
        grep -E '^(audio|video)/' |
        sort -u |
        while IFS= read -r media_type; do
            [ -n "$media_type" ] &&
                xdg-mime default "$celluloid_desktop" "$media_type"
        done
fi

echo "Stage 9 media tools applied."
if [ "${VOID_EXPERIENCE_SHARED_MEDIA_DEFAULTS-0}" != 1 ]; then
    echo "Shared audio/video MIME defaults were left unchanged."
fi
echo "Close and reopen Thunar once to load the Space shortcut."
