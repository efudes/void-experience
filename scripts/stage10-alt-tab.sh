#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
theme_source="$project_dir/themes/Void-Experience"
theme_target="$HOME/.themes/Void-Experience"

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *)
        echo "Refusing Alt+Tab styling outside XFCE/X11." >&2
        exit 1
        ;;
esac

mkdir -p "$theme_target/gtk-3.0"
install -m 0644 "$theme_source/gtk-3.0/gtk.css" \
    "$theme_target/gtk-3.0/gtk.css"

set_xfwm_bool() {
    xfconf-query -c xfwm4 -p "/general/$1" -s "$2"
}

# Compact current-workspace list. Hidden/iconified windows remain available;
# xfwm4 4.20 exposes no per-iconified-row CSS state, so all unselected rows
# use the same restrained treatment.
set_xfwm_bool cycle_minimum true
set_xfwm_bool cycle_minimized true
set_xfwm_bool cycle_hidden true
set_xfwm_bool cycle_workspaces false
set_xfwm_bool cycle_draw_frame false
set_xfwm_bool cycle_raise false
set_xfwm_bool cycle_preview false
xfconf-query -c xfwm4 -p /general/cycle_tabwin_mode -s 1

echo "Stage 10 Alt+Tab list styling applied."
echo "Restart xfwm4 or log into XFCE again to reload its GTK CSS provider."
