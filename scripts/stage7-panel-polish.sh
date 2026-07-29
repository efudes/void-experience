#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
theme_source="$project_dir/themes/Void-Experience"
theme_target="$HOME/.themes/Void-Experience"

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *) echo "Refusing panel polish outside XFCE/X11." >&2; exit 1 ;;
esac

active_outputs_primary_first() {
    xrandr --listactivemonitors | awk '
        NR > 1 {
            if ($2 ~ /\*/)
                primary = primary $NF ORS
            else
                secondary = secondary $NF ORS
        }
        END { printf "%s%s", primary, secondary }
    '
}

mkdir -p "$theme_target/gtk-3.0"
install -m 0644 "$theme_source/index.theme" "$theme_target/index.theme"
install -m 0644 "$theme_source/gtk-3.0/gtk.css" \
    "$theme_target/gtk-3.0/gtk.css"
install -m 0644 "$theme_source/gtk-3.0/gtk-dark.css" \
    "$theme_target/gtk-3.0/gtk-dark.css"
ln -sfn /usr/share/themes/Arc-Dark/gtk-3.0/gtk.gresource \
    "$theme_target/gtk-3.0/gtk.gresource"

for layout_name in us ru; do
    install -Dm0644 "$project_dir/assets/xkb/$layout_name.svg" \
        "$HOME/.local/share/xfce4/xkb/flags/$layout_name.svg"
done
install -Dm0644 "$project_dir/assets/icons/void-experience-menu.svg" \
    "$HOME/.local/share/icons/hicolor/scalable/apps/void-experience-menu.svg"

# Stage 1 reserves twenty plugin IDs per monitor. Render GenMon configuration
# with the current user's HOME instead of embedding a workstation path.
monitor_index=0
outputs=$(active_outputs_primary_first)
for _output in $outputs; do
    network_id=$((806 + monitor_index * 20))
    mkdir -p "$HOME/.config/xfce4/panel"
    sed "s|@HOME@|$HOME|g" "$project_dir/configs/xfce4/genmon-network.rc" \
        >"$HOME/.config/xfce4/panel/genmon-$network_id.rc"
    monitor_index=$((monitor_index + 1))
done

# XFCE consumes xsettings; GNOME uses its own settings daemon.
xfconf-query -c xsettings -p /Net/ThemeName -n \
    -t string -s 'Void-Experience'
xfce4-panel --restart

echo "Stage 7 panel polish applied."
