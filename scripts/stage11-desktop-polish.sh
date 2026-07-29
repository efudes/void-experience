#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
icon_source="$project_dir/themes/Void-Experience-Icons"
icon_target="$HOME/.local/share/icons/Void-Experience-Icons"
desktop_dir=$(xdg-user-dir DESKTOP 2>/dev/null || true)
[ -n "$desktop_dir" ] || desktop_dir="$HOME/Desktop"

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *) echo "Refusing desktop polish outside XFCE/X11." >&2; exit 1 ;;
esac

mkdir -p "$icon_target"
cp -a "$icon_source/." "$icon_target/"
gtk-update-icon-cache -f -t "$icon_target" >/dev/null 2>&1 || true

# XFCE consumes this xsettings channel. GNOME uses gsettings and its own
# settings daemon, so the GNOME icon theme is not changed.
xfconf-query -c xsettings -p /Net/IconThemeName -n \
    -t string -s 'Void-Experience-Icons'

# Xfdesktop cannot hide captions independently from symbolic icon rendering.
# Replace its three special icons with equivalent zero-width-name launchers.
xfconf-query -c xfce4-desktop -p /desktop-icons/style -n -t int -s 2
xfconf-query -c xfce4-desktop \
    -p /desktop-icons/use-custom-font-size -n -t bool -s false
for special_icon in show-home show-filesystem show-trash; do
    xfconf-query -c xfce4-desktop \
        -p "/desktop-icons/file-icons/$special_icon" -n -t bool -s false
done

mkdir -p "$desktop_dir"
for launcher in void-home void-filesystem void-trash; do
    install -m 0755 \
        "$project_dir/configs/xfce4/desktop-icons/$launcher.desktop" \
        "$desktop_dir/Void-${launcher#void-}.desktop"
done

# Keep user-chosen labels (including whitespace-only labels) and decorate
# existing Downloads/Documents symlinks instead of replacing them.
downloads_dir=$(xdg-user-dir DOWNLOAD 2>/dev/null || true)
documents_dir=$(xdg-user-dir DOCUMENTS 2>/dev/null || true)
[ -n "$downloads_dir" ] || downloads_dir="$HOME/Downloads"
[ -n "$documents_dir" ] || documents_dir="$HOME/Documents"

find "$desktop_dir" -mindepth 1 -maxdepth 1 -type l -print |
while IFS= read -r shortcut; do
    target=$(readlink -f -- "$shortcut" 2>/dev/null || true)
    case "$target" in
        "$downloads_dir")
            icon_file="$icon_target/48x48/places/void-downloads.svg"
            ;;
        "$documents_dir")
            icon_file="$icon_target/48x48/places/void-documents.svg"
            ;;
        *)
            continue
            ;;
    esac
    gio set -t string "$shortcut" metadata::custom-icon \
        "$(gio info -a standard::target-uri "$icon_file" |
            sed -n 's/^uri: //p')" 2>/dev/null || true
done

xfdesktop --reload >/dev/null 2>&1 || true
echo "Stage 11 desktop icon polish applied."
