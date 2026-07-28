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

picom --config "$HOME/.config/picom/picom.conf" --diagnostics >/dev/null

if pgrep -x picom >/dev/null 2>&1; then
    pkill -TERM -x picom
    for _attempt in $(seq 1 30); do
        pgrep -x picom >/dev/null 2>&1 || break
        sleep 0.1
    done
fi

picom --config "$HOME/.config/picom/picom.conf" --daemon
