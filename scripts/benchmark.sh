#!/bin/sh
set -u

echo "[memory]"
free -h

echo
echo "[desktop processes]"
ps -eo pid,comm,%cpu,%mem,rss --sort=-rss |
    awk 'NR == 1 || $2 ~ /^(xfwm4|xfce4-panel|picom|rofi|xdotool|wmctrl)$/'

echo
echo "[compositors]"
pgrep -a 'picom|xfwm4' 2>&1 || true

echo
echo "[recent user-session warnings]"
journalctl --user -b -p warning --no-pager -n 100 2>&1 || true
