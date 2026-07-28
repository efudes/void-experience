#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
theme_source="$project_dir/themes/Void-Experience"
theme_target="$HOME/.themes/Void-Experience"

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *)
        echo "Refusing lock-screen styling outside XFCE/X11." >&2
        exit 1
        ;;
esac

command -v xfce4-screensaver-command >/dev/null 2>&1 || {
    echo "xfce4-screensaver is not installed." >&2
    exit 1
}

mkdir -p "$theme_target/gtk-3.0"
install -m 0644 "$theme_source/index.theme" "$theme_target/index.theme"
install -m 0644 "$theme_source/gtk-3.0/gtk.css" \
    "$theme_target/gtk-3.0/gtk.css"
install -m 0644 "$theme_source/gtk-3.0/gtk-dark.css" \
    "$theme_target/gtk-3.0/gtk-dark.css"
ln -sfn /usr/share/themes/Arc-Dark/gtk-3.0/gtk.gresource \
    "$theme_target/gtk-3.0/gtk.gresource"

# The authentication dialog is a fresh process on every lock and therefore
# reads this CSS without restarting the long-lived screensaver daemon.

echo "Stage 8 XFCE lock-screen styling applied."
