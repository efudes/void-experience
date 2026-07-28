#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

case "${XDG_CURRENT_DESKTOP-}" in
    *XFCE*) ;;
    *)
        echo "Refusing Rofi shortcut changes outside XFCE." >&2
        exit 1
        ;;
esac

command -v rofi >/dev/null 2>&1 || {
    echo "Rofi is not installed." >&2
    exit 1
}

"$project_dir/scripts/apply.sh"

shortcut='/commands/custom/<Super>r'
xfconf-query -c xfce4-keyboard-shortcuts -p "$shortcut" \
    -n -t string -s 'rofi -show drun'
xfconf-query -c xfce4-keyboard-shortcuts \
    -p "$shortcut/startup-notify" -r 2>/dev/null || true
