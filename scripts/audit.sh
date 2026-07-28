#!/bin/sh
set -u

echo "Void Experience audit"
echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP-}"
echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE-}"
echo "DISPLAY=${DISPLAY-}"

xfce4-session --version 2>&1 || true
xfwm4 --version 2>&1 || true
picom --version 2>&1 || true

for channel in xfce4-panel xfwm4 xfce4-keyboard-shortcuts xfce4-session; do
    echo
    echo "[$channel]"
    xfconf-query -c "$channel" -lv 2>&1 || true
done

echo
echo "[autostart]"
find "$HOME/.config/autostart" -maxdepth 1 -type f -print 2>&1 || true

echo
echo "[processes]"
pgrep -a 'xfwm4|picom|xfce4-panel' 2>&1 || true

echo
echo "[monitors]"
xrandr --listmonitors 2>&1 || true
xrandr --query 2>&1 || true

echo
echo "[user services]"
systemctl --user list-unit-files --state=enabled --no-pager 2>&1 || true

echo
echo "[packages]"
apt-cache policy rofi wmctrl xdotool xfce4-panel-profiles \
    xfce4-docklike-plugin picom
