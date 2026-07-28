#!/bin/sh
set -eu

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *) exit 0 ;;
esac

runtime_dir=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
lock_file="$runtime_dir/void-experience-panel-watch.lock"
exec 9>"$lock_file"
flock -n 9 || exit 0

fingerprint() {
    xrandr --listactivemonitors 2>/dev/null | sed -n '2,$p'
}

previous=$(fingerprint)
while sleep 2; do
    current=$(fingerprint)
    [ "$current" = "$previous" ] && continue
    sleep 2
    configurator="$HOME/.local/lib/void-experience/configure-panels"
    if [ -x "$configurator" ]; then
        "$configurator" >/dev/null 2>&1 || xfce4-panel --restart
    else
        xfce4-panel --restart
    fi
    previous=$(fingerprint)
done
