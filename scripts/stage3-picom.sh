#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *)
        echo "Refusing Picom changes outside XFCE/X11." >&2
        exit 1
        ;;
esac

"$project_dir/scripts/apply.sh"

glx_config="$HOME/.config/picom/picom.conf"
xrender_config="$HOME/.config/picom/picom-xrender.conf"
if picom --config "$glx_config" --diagnostics >/dev/null 2>&1; then
    selected_config=$glx_config
    selected_backend=GLX
elif picom --config "$xrender_config" --diagnostics >/dev/null 2>&1; then
    selected_config=$xrender_config
    selected_backend=XRender
else
    # A working compositor is more important than rounded corners. Keep this
    # fallback scoped to xfwm4 inside the current XFCE session.
    xfconf-query -c xfwm4 -p /general/use_compositing -s true
    echo "No usable Picom backend; restored the xfwm4 compositor." >&2
    exit 1
fi

if pgrep -x picom >/dev/null 2>&1; then
    pkill -TERM -x picom
    for _attempt in $(seq 1 30); do
        pgrep -x picom >/dev/null 2>&1 || break
        sleep 0.1
    done
fi

picom --config "$selected_config" --daemon
echo "Picom started with $selected_backend backend."
