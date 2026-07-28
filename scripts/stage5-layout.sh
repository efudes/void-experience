#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *)
        echo "Refusing layout changes outside XFCE/X11." >&2
        exit 1
        ;;
esac

for required in rofi wmctrl xdotool; do
    command -v "$required" >/dev/null 2>&1 || {
        echo "Missing package command: $required" >&2
        exit 1
    }
done

# An 8 px layout gap must sit outside xfwm4's magnetic snap threshold.
xfconf-query -c xfwm4 -p /general/snap_width -s 4

install -Dm0755 "$project_dir/scripts/void-layout.sh" \
    "$HOME/.local/bin/void-layout"

xfconf-query -c xfce4-keyboard-shortcuts \
    -p '/commands/custom/<Super>z' -n -t string -s \
    "$HOME/.local/bin/void-layout"

set_layout_shortcut() {
    xfconf-query -c xfce4-keyboard-shortcuts \
        -p "$1" -n -t string -s "$HOME/.local/bin/void-layout $2"
}

set_layout_shortcut '/commands/custom/<Super>Left' half-left
set_layout_shortcut '/commands/custom/<Super>Right' half-right
set_layout_shortcut '/commands/custom/<Super>Up' maximize
set_layout_shortcut '/commands/custom/<Super><Shift>Up' fill-gapped
set_layout_shortcut '/commands/custom/<Super><Alt>Left' third-left
set_layout_shortcut '/commands/custom/<Super><Alt>Right' third-right
set_layout_shortcut '/commands/custom/<Super><Shift>Left' twothirds-left
set_layout_shortcut '/commands/custom/<Super><Shift>Right' twothirds-right
