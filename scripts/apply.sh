#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

case "${XDG_CURRENT_DESKTOP-}" in
    *XFCE*) ;;
    *)
        echo "Refusing to apply outside an XFCE session." >&2
        exit 1
        ;;
esac

install_file() {
    source_file=$1
    target_file=$2
    [ -f "$source_file" ] || return 0
    mkdir -p "$(dirname -- "$target_file")"
    if [ -f "$target_file" ] && cmp -s "$source_file" "$target_file"; then
        return 0
    fi
    install -m 0644 "$source_file" "$target_file"
}

install_executable() {
    source_file=$1
    target_file=$2
    [ -f "$source_file" ] || return 0
    mkdir -p "$(dirname -- "$target_file")"
    install -m 0755 "$source_file" "$target_file"
}

install_file "$project_dir/configs/picom/picom.conf" \
    "$HOME/.config/picom/picom.conf"
install_file "$project_dir/configs/rofi/config.rasi" \
    "$HOME/.config/rofi/config.rasi"
install_file "$project_dir/configs/rofi/void-experience.rasi" \
    "$HOME/.config/rofi/void-experience.rasi"
install_file "$project_dir/configs/autostart/void-experience-picom.desktop" \
    "$HOME/.config/autostart/void-experience-picom.desktop"
install_file "$project_dir/configs/autostart/void-experience-panel-watch.desktop" \
    "$HOME/.config/autostart/void-experience-panel-watch.desktop"
install_file "$project_dir/configs/autostart/xfce4-clipman-plugin-autostart.desktop" \
    "$HOME/.config/autostart/xfce4-clipman-plugin-autostart.desktop"
install_executable "$project_dir/scripts/xfce-only-picom.sh" \
    "$HOME/.local/bin/void-experience-picom"
install_executable "$project_dir/scripts/void-panel-watch.sh" \
    "$HOME/.local/bin/void-panel-watch"
install_executable "$project_dir/scripts/stage1-panel.sh" \
    "$HOME/.local/lib/void-experience/configure-panels"
install_executable "$project_dir/scripts/void-layout.sh" \
    "$HOME/.local/bin/void-layout"
install_executable "$project_dir/scripts/void-network-indicator.sh" \
    "$HOME/.local/bin/void-network-indicator"
install_executable "$project_dir/scripts/void-preview" \
    "$HOME/.local/bin/void-preview"
install_executable "$project_dir/scripts/void-toggle-desktop" \
    "$HOME/.local/bin/void-toggle-desktop"
install_file "$project_dir/configs/xfce4/genmon-network.rc" \
    "$HOME/.local/share/void-experience/genmon-network.rc"

if [ -d "$project_dir/themes/Void-Experience/xfwm4" ]; then
    mkdir -p "$HOME/.themes/Void-Experience"
    cp -a "$project_dir/themes/Void-Experience/xfwm4" \
        "$HOME/.themes/Void-Experience/"
fi

mkdir -p "$HOME/Pictures/Void-Experience"

case "${1-}" in
    --stage1-panel)
        "$project_dir/scripts/stage1-panel.sh"
        ;;
    --stage2-windows)
        "$project_dir/scripts/stage2-windows.sh"
        ;;
    --stage3-picom)
        "$project_dir/scripts/stage3-picom.sh"
        ;;
    --stage4-rofi)
        "$project_dir/scripts/stage4-rofi.sh"
        ;;
    --stage5-layout)
        "$project_dir/scripts/stage5-layout.sh"
        ;;
    --stage6-cohesion)
        "$project_dir/scripts/stage6-cohesion.sh"
        ;;
    --stage7-panel-polish)
        "$project_dir/scripts/stage7-panel-polish.sh"
        ;;
    --stage8-lockscreen)
        "$project_dir/scripts/stage8-lockscreen.sh"
        ;;
    --stage9-media)
        "$project_dir/scripts/stage9-media.sh"
        ;;
    --stage10-alt-tab)
        "$project_dir/scripts/stage10-alt-tab.sh"
        ;;
    --stage11-desktop-polish)
        "$project_dir/scripts/stage11-desktop-polish.sh"
        ;;
    --all)
        "$project_dir/scripts/stage7-panel-polish.sh"
        "$project_dir/scripts/stage1-panel.sh"
        "$project_dir/scripts/stage2-windows.sh"
        "$project_dir/scripts/stage3-picom.sh"
        "$project_dir/scripts/stage4-rofi.sh"
        "$project_dir/scripts/stage5-layout.sh"
        "$project_dir/scripts/stage6-cohesion.sh"
        "$project_dir/scripts/stage8-lockscreen.sh"
        "$project_dir/scripts/stage9-media.sh"
        "$project_dir/scripts/stage10-alt-tab.sh"
        "$project_dir/scripts/stage11-desktop-polish.sh"
        ;;
    "")
        ;;
    *)
        echo "Unknown apply mode: ${1-}" >&2
        exit 2
        ;;
esac

echo "Project-owned files installed."
