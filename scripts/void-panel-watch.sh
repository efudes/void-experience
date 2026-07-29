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
    found=false
    for status_file in /sys/class/drm/card*-*/status; do
        [ -r "$status_file" ] || continue
        found=true
        connector_dir=${status_file%/status}
        printf '%s:' "${connector_dir##*/}"
        cat "$status_file"
    done
    if ! "$found"; then
        # Non-DRM X servers are uncommon on the supported Debian/Xorg target.
        # Keep a functional fallback, but avoid the aggressive polling cadence
        # that can produce RandR/EDID storms with modesetting drivers.
        xrandr --listactivemonitors 2>/dev/null | sed -n '2,$p'
    fi
}

previous=$(fingerprint)
while sleep 5; do
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
