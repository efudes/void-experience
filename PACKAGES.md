# Packages

`install.sh` uses Debian 13 packages only:

| Area | Packages |
|---|---|
| Desktop | `xfce4`, `xfce4-goodies`, `thunar`, `tumbler` |
| Panel | `xfce4-panel-profiles`, `xfce4-whiskermenu-plugin`, `xfce4-pulseaudio-plugin`, `xfce4-xkb-plugin`, `xfce4-genmon-plugin` |
| Appearance | `arc-theme`, `papirus-icon-theme`, `bibata-cursor-theme` |
| Compositor/launcher | `picom`, `rofi` |
| Window layouts | `wmctrl`, `xdotool`, `x11-utils`, `x11-xserver-utils` |
| Session | `xfce4-screensaver`, `network-manager-gnome`, `kitty` |
| Media | `celluloid`, `gnome-sushi`, `ffmpeg`, `libmpv2` |
| Helpers | `libnotify-bin` |

The project does not add third-party APT repositories or execute downloaded
scripts. Rollback retains packages to avoid removing dependencies used by other
desktop sessions.
