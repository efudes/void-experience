#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
kitty_dir="$HOME/.config/kitty"
kitty_main="$kitty_dir/kitty.conf"
kitty_overlay="$kitty_dir/void-experience.conf"
include_line='include void-experience.conf'
xfce_xinitrc="$HOME/.config/xfce4/xinitrc"

case "${XDG_CURRENT_DESKTOP-}" in
    *XFCE*) ;;
    *)
        echo "Refusing to change live appearance outside XFCE." >&2
        exit 1
        ;;
esac

# These values live in xfconf and are consumed by XFCE's xsettings daemon.
# GNOME does not use this channel for its theme or cursor configuration.
xfconf-query -c xsettings -p /Gtk/CursorThemeName -n \
    -t string -s 'Bibata-Modern-Ice'
xfconf-query -c xsettings -p /Net/EnableEventSounds -n \
    -t bool -s false
xfconf-query -c xsettings -p /Net/EnableInputFeedbackSounds -n \
    -t bool -s false

# XFCE-only session environment for Qt/Flatpak applications. A wrapper keeps
# Debian's system xinitrc authoritative, so package updates are not copied or
# frozen in the user's configuration.
install -Dm0755 "$project_dir/configs/xfce4/xinitrc" "$xfce_xinitrc"

mkdir -p "$kitty_dir"
install -m 0644 "$project_dir/configs/kitty/void-experience.conf" "$kitty_overlay"

# Keep the existing Kitty configuration intact and add one idempotent overlay.
if [ -f "$kitty_main" ]; then
    grep -Fxq "$include_line" "$kitty_main" ||
        printf '\n%s\n' "$include_line" >>"$kitty_main"
else
    printf '%s\n' "$include_line" >"$kitty_main"
fi

echo "Stage 6 cohesion settings applied."
