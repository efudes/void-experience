#!/bin/sh
set -eu

case "${XDG_CURRENT_DESKTOP-}" in
    *XFCE*) ;;
    *) exit 0 ;;
esac

[ "${XDG_SESSION_TYPE-}" = x11 ] || exit 0

if pgrep -x picom >/dev/null 2>&1; then
    exit 0
fi

exec picom --config "$HOME/.config/picom/picom.conf"
