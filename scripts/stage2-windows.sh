#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

case "${XDG_CURRENT_DESKTOP-}" in
    *XFCE*) ;;
    *)
        echo "Refusing window-manager changes outside an XFCE session." >&2
        exit 1
        ;;
esac

theme_source="$project_dir/themes/Void-Experience/xfwm4"
theme_target="$HOME/.themes/Void-Experience/xfwm4"

[ -f "$theme_source/themerc" ] || {
    echo "Theme source is incomplete." >&2
    exit 1
}

mkdir -p "$theme_target"
cp -a "$theme_source/." "$theme_target/"

set_wm_string() {
    xfconf-query -c xfwm4 -p "$1" -n -t string -s "$2"
}

set_wm_bool() {
    xfconf-query -c xfwm4 -p "$1" -n -t bool -s "$2"
}

set_shortcut() {
    xfconf-query -c xfce4-keyboard-shortcuts -p "$1" -n -t string -s "$2"
}

set_wm_string /general/theme Void-Experience
set_wm_string /general/button_layout 'O|HMC'
set_wm_string /general/title_alignment center
set_wm_string /general/title_font 'Noto Sans Medium 9'
set_wm_bool /general/borderless_maximize true
set_wm_bool /general/titleless_maximize false
set_wm_bool /general/tile_on_move true
set_wm_bool /general/use_compositing false
xfconf-query -c xfwm4 -p /general/snap_width -s 4
xfconf-query -c xfwm4 -p /general/margin_top -s 0
xfconf-query -c xfwm4 -p /general/margin_right -s 0
xfconf-query -c xfwm4 -p /general/margin_bottom -s 0
xfconf-query -c xfwm4 -p /general/margin_left -s 0

# Application launchers. Super+R remains Appfinder until Rofi is installed.
set_shortcut '/commands/custom/<Super>t' kitty
set_shortcut '/commands/custom/<Super>e' thunar
set_shortcut '/commands/custom/<Super>l' 'xfce4-screensaver-command --lock'
set_shortcut '/commands/custom/Print' 'flameshot gui'
set_shortcut '/commands/custom/<Shift>Print' 'xfce4-screenshooter'
install -Dm0755 "$project_dir/scripts/void-toggle-desktop" \
    "$HOME/.local/bin/void-toggle-desktop"
xfconf-query -c xfce4-keyboard-shortcuts \
    -p '/xfwm4/custom/<Super>d' -r 2>/dev/null || true
set_shortcut '/commands/custom/<Super>d' \
    "$HOME/.local/bin/void-toggle-desktop"
xfconf-query -c xfce4-session -p /general/LockCommand -n \
    -t string -s 'xfce4-screensaver-command --lock'

# Workspace navigation.
set_shortcut '/xfwm4/custom/<Super>1' workspace_1_key
set_shortcut '/xfwm4/custom/<Super>2' workspace_2_key
set_shortcut '/xfwm4/custom/<Super>3' workspace_3_key
set_shortcut '/xfwm4/custom/<Super>4' workspace_4_key
set_shortcut '/xfwm4/custom/<Super><Shift>1' move_window_workspace_1_key
set_shortcut '/xfwm4/custom/<Super><Shift>2' move_window_workspace_2_key
set_shortcut '/xfwm4/custom/<Super><Shift>3' move_window_workspace_3_key
set_shortcut '/xfwm4/custom/<Super><Shift>4' move_window_workspace_4_key
set_shortcut '/xfwm4/custom/<Super><Primary>Left' left_workspace_key
set_shortcut '/xfwm4/custom/<Super><Primary>Right' right_workspace_key
