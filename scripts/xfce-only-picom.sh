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

glx_config="$HOME/.config/picom/picom.conf"
xrender_config="$HOME/.config/picom/picom-xrender.conf"

if picom --config "$glx_config" --diagnostics >/dev/null 2>&1; then
    exec picom --config "$glx_config"
elif [ -r "$xrender_config" ] &&
    picom --config "$xrender_config" --diagnostics >/dev/null 2>&1; then
    exec picom --config "$xrender_config"
fi

echo "No usable Picom GLX or XRender backend; leaving compositor stopped." >&2
exit 1
