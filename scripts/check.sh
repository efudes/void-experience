#!/bin/sh
set -u

failures=0

pass() { echo "PASS: $*"; }
warn() { echo "WARN: $*"; }
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }

case "${XDG_CURRENT_DESKTOP-}" in
    *XFCE*) pass "running in XFCE" ;;
    *) warn "not running in XFCE; live checks are limited" ;;
esac

for command_name in xfwm4 xfce4-panel picom; do
    if command -v "$command_name" >/dev/null 2>&1; then
        pass "$command_name is installed"
    else
        fail "$command_name is missing"
    fi
done

for optional_command in rofi wmctrl xdotool; do
    if command -v "$optional_command" >/dev/null 2>&1; then
        pass "$optional_command is installed"
    else
        warn "$optional_command is not installed yet"
    fi
done

if command -v fc-match >/dev/null 2>&1 &&
    fc-match --format '%{family}\n' 'Noto Sans' |
        grep -qi 'Noto Sans'; then
    pass "Noto Sans is installed"
else
    warn "Noto Sans is missing; Rofi/xfwm will use a fallback font"
fi

if command -v flameshot >/dev/null 2>&1 &&
    xfconf-query -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/Print' 2>/dev/null |
        grep -qx 'flameshot gui'; then
    pass "Print launches Flameshot"
else
    warn "Print is not configured for Flameshot"
fi

if command -v xfce4-screenshooter >/dev/null 2>&1 &&
    xfconf-query -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/<Shift>Print' 2>/dev/null |
        grep -qx 'xfce4-screenshooter'; then
    pass "Shift+Print launches XFCE Screenshooter"
else
    warn "Shift+Print is not configured for XFCE Screenshooter"
fi

if command -v xfce4-clipman-history >/dev/null 2>&1 &&
    xfconf-query -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/<Super>v' 2>/dev/null |
        grep -qx 'xfce4-clipman-history'; then
    pass "Super+V opens clipboard history"
else
    warn "Super+V clipboard history is not configured"
fi

if [ -x "$HOME/.local/bin/xfwm4" ] &&
    [ -r "$HOME/.local/lib/void-experience/libxfwm-null-hash-guard.so" ]; then
    pass "xfwm4 external-compositor NULL guard is installed"
else
    warn "xfwm4 external-compositor NULL guard is not installed"
fi

if [ -f "$HOME/.config/autostart/xfce4-clipman-plugin-autostart.desktop" ] &&
    grep -qx 'OnlyShowIn=XFCE;' \
        "$HOME/.config/autostart/xfce4-clipman-plugin-autostart.desktop"; then
    pass "Clipman autostart is XFCE-only"
else
    warn "XFCE-only Clipman autostart is not installed"
fi

if xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null |
    grep -qx 'Void-Experience-Icons'; then
    pass "XFCE uses the Void Experience icon layer"
else
    warn "XFCE desktop icon layer is not active"
fi

desktop_dir=$(xdg-user-dir DESKTOP 2>/dev/null || true)
[ -n "$desktop_dir" ] || desktop_dir="$HOME/Desktop"
desktop_launchers_ok=true
for launcher in Void-home Void-filesystem Void-trash; do
    [ -x "$desktop_dir/$launcher.desktop" ] || desktop_launchers_ok=false
done
if "$desktop_launchers_ok"; then
    pass "label-free XFCE desktop launchers are installed"
else
    warn "label-free XFCE desktop launchers are incomplete"
fi

for icon_name in void-downloads void-documents; do
    if [ -f "$HOME/.local/share/icons/Void-Experience-Icons/48x48/places/$icon_name.svg" ]; then
        pass "$icon_name desktop icon is installed"
    else
        warn "$icon_name desktop icon is missing"
    fi
done

picom_count=$(pgrep -x picom 2>/dev/null | wc -l)
if [ "$picom_count" -le 1 ]; then
    pass "no duplicate Picom process detected"
else
    fail "multiple Picom processes detected: $picom_count"
fi

if xfconf-query -c xfwm4 -p /general/use_compositing 2>/dev/null |
    grep -qx false; then
    pass "xfwm4 compositor is disabled"
else
    warn "cannot confirm that xfwm4 compositor is disabled"
fi

if [ -f "$HOME/.config/autostart/void-experience-picom.desktop" ]; then
    if grep -qx 'OnlyShowIn=XFCE;' \
        "$HOME/.config/autostart/void-experience-picom.desktop"; then
        pass "Picom autostart is XFCE-only"
    else
        fail "Picom autostart lacks OnlyShowIn=XFCE;"
    fi
else
    warn "Void Experience Picom autostart is not installed yet"
fi

if [ -x "$HOME/.local/bin/void-layout" ]; then
    pass "Void Layout helper is installed"
else
    warn "Void Layout helper is not installed yet"
fi

if command -v xfce4-screensaver-command >/dev/null 2>&1; then
    pass "XFCE screensaver/locker is installed"
    if xfce4-screensaver-command --query >/dev/null 2>&1; then
        pass "XFCE screensaver/locker is running"
    else
        fail "XFCE screensaver/locker is not running"
    fi
else
    fail "XFCE screensaver/locker is missing"
fi

if [ -f "$HOME/.themes/Void-Experience/gtk-3.0/gtk.css" ] &&
    grep -Fq '#login_window' \
        "$HOME/.themes/Void-Experience/gtk-3.0/gtk.css"; then
    pass "Void Experience lock-screen theme is installed"
else
    warn "Void Experience lock-screen theme is not installed"
fi

if [ -x "$HOME/.local/bin/void-panel-watch" ]; then
    pass "panel hotplug guard is installed"
else
    warn "panel hotplug guard is not installed yet"
fi

if xfconf-query -c xsettings -p /Gtk/CursorThemeName 2>/dev/null |
    grep -qx 'Bibata-Modern-Ice'; then
    pass "XFCE cursor is Bibata-Modern-Ice"
else
    warn "XFCE cursor is not explicitly Bibata-Modern-Ice"
fi

if [ -f "$HOME/.config/kitty/void-experience.conf" ] &&
    grep -Eq '^[[:space:]]*background_opacity[[:space:]]+0[.]96[[:space:]]*$' \
        "$HOME/.config/kitty/void-experience.conf"; then
    pass "Kitty Void Experience overlay is installed"
else
    warn "Kitty Void Experience overlay is not installed"
fi

if [ -x "$HOME/.config/xfce4/xinitrc" ] &&
    grep -Fq "XCURSOR_THEME='Bibata-Modern-Ice'" \
        "$HOME/.config/xfce4/xinitrc"; then
    pass "XFCE-only cursor environment is installed"
else
    warn "XFCE-only cursor environment is not installed"
fi

if xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null |
    grep -qx 'Void-Experience'; then
    pass "XFCE uses the Void Experience panel theme"
else
    warn "XFCE does not use the Void Experience panel theme"
fi

if [ -x "$HOME/.local/bin/void-network-indicator" ] &&
    command -v nm-connection-editor >/dev/null 2>&1; then
    pass "Void Network indicator and editor are installed"
else
    warn "Void Network indicator or nm-connection-editor is missing"
fi

panel_state=$(xfconf-query -c xfce4-panel -lv 2>/dev/null || true)

if printf '%s\n' "$panel_state" |
    awk '$1 ~ /^\/plugins\/plugin-[0-9]+$/ && $2 == "xkb" { found=1 }
         END { exit !found }'; then
    pass "primary-panel XKB indicator is installed"
else
    warn "primary-panel XKB indicator is not installed"
fi

if command -v celluloid >/dev/null 2>&1; then
    pass "Celluloid media player is installed"
else
    warn "Celluloid media player is not installed"
fi

if command -v sushi >/dev/null 2>&1 &&
    [ -x "$HOME/.local/bin/void-preview" ] &&
    grep -Fq '<unique-id>void-experience-preview</unique-id>' \
        "$HOME/.config/Thunar/uca.xml" 2>/dev/null &&
    grep -Fq \
        '<Actions>/ThunarActions/uca-action-void-experience-preview' \
        "$HOME/.config/Thunar/accels.scm" 2>/dev/null; then
    pass "Thunar Space preview via Sushi is installed"
else
    warn "Thunar Space preview via Sushi is incomplete"
fi

if xfconf-query -c xfwm4 -p /general/cycle_tabwin_mode 2>/dev/null |
    grep -qx 1 &&
    xfconf-query -c xfwm4 -p /general/cycle_hidden 2>/dev/null |
        grep -qx true &&
    grep -Fq '#xfwm-tabwin' \
        "$HOME/.themes/Void-Experience/gtk-3.0/gtk.css" 2>/dev/null; then
    pass "Void Experience Alt+Tab list is configured"
else
    warn "Void Experience Alt+Tab list is incomplete"
fi

if [ -x "$HOME/.local/bin/void-toggle-desktop" ] &&
    xfconf-query -c xfce4-keyboard-shortcuts \
        -p '/commands/custom/<Super>d' 2>/dev/null |
        grep -qx "$HOME/.local/bin/void-toggle-desktop"; then
    pass "Super+D toggles the XFCE desktop"
else
    warn "Super+D desktop toggle is not configured"
fi

menu_icon="$HOME/.local/share/icons/hicolor/scalable/apps/void-experience-menu.svg"
whisker_ids=$(printf '%s\n' "$panel_state" |
    awk '$1 ~ /^\/plugins\/plugin-[0-9]+$/ && $2 == "whiskermenu" {
        sub("^/plugins/plugin-", "", $1)
        print $1
    }')
menu_icons_ok=true
[ -n "$whisker_ids" ] || menu_icons_ok=false
for plugin_id in $whisker_ids; do
    xfconf-query -c xfce4-panel \
        -p "/plugins/plugin-$plugin_id/button-icon" 2>/dev/null |
        grep -Fqx "$menu_icon" || menu_icons_ok=false
done
if [ -f "$menu_icon" ] && "$menu_icons_ok"; then
    pass "Void Experience Whisker buttons use the custom launcher icon"
else
    warn "Void Experience Whisker button icon is incomplete"
fi

active_monitors=$(xrandr --listactivemonitors 2>/dev/null |
    awk 'NR > 1 { count++ } END { print count+0 }')
portable_panels=$(printf '%s\n' "$panel_state" |
    awk '$1 ~ /^\/panels\/panel-8[1-9]\/output-name$/ { count++ }
         END { print count+0 }')
if [ "$portable_panels" -eq 0 ]; then
    warn "portable monitor-aware panel profile is not installed on this machine"
elif [ "$portable_panels" -eq "$active_monitors" ]; then
    pass "one portable panel is configured per active monitor"
else
    fail "portable panel/monitor count differs: $portable_panels/$active_monitors"
fi

exit "$failures"
