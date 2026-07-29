# Packages

`install.sh` splits software into a mandatory, reproducible Debian core and an
explicit optional checklist.

| Area | Packages |
|---|---|
| Desktop | `xfce4`, `thunar`, `tumbler` |
| Panel | `xfce4-panel-profiles`, `xfce4-whiskermenu-plugin`, `xfce4-pulseaudio-plugin`, `xfce4-xkb-plugin`, `xfce4-genmon-plugin` |
| Appearance | `arc-theme`, `papirus-icon-theme`, `bibata-cursor-theme` |
| Fonts | `fonts-noto-core`, `fontconfig` |
| Compositor/launcher | `picom`, `rofi` |
| Window layouts | `wmctrl`, `xdotool`, `x11-utils`, `x11-xserver-utils` |
| Session | `xfce4-screensaver`, `network-manager-gnome`, `kitty` |
| Screenshots | `flameshot`, `xfce4-screenshooter` |
| Clipboard | `xfce4-clipman` |
| Media core | `celluloid`, `gnome-sushi`, `ffmpeg`, `libmpv2` |
| Helpers/build | `libnotify-bin`, `xdg-user-dirs`, `xdg-utils`, `util-linux`, `procps`, `libgtk-3-bin`, `whiptail`, `bash`, `gcc`, `libc6-dev` |

Flatpak/Flathub, Steam, Lutris, Discord, PortProton, ani-cli and Void Zsh are
off by default.
Selecting a Flatpak app explicitly adds Flathub as a **per-user** remote.

| Optional app | Source | Application ID |
|---|---|---|
| Steam | Flathub community package (unverified by Valve) | `com.valvesoftware.Steam` |
| Lutris | Flathub | `net.lutris.Lutris` |
| Discord | Flathub, proprietary | `com.discordapp.Discord` |
| PortProton | Flathub, x86_64 only | `ru.linux_gaming.PortProton` |
| ani-cli | Debian 13 | `ani-cli` |
| Void Zsh | Debian 13 + bundled OFL font | `zsh`, `starship`, `zoxide`, `eza`, `bat`, `ripgrep`, `fd-find`, `fastfetch`, `btop`, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting` |

Void Zsh never imports a raw user `.zshrc`. It installs a project-owned profile
and adds one marked source block after the timestamped backup exists. Login
shell replacement is confirmed separately and rollback restores the recorded
baseline shell.

No third-party APT repository is added and no downloaded shell script is
executed. Rollback retains packages to avoid removing dependencies used by
other desktop sessions.

Picom prefers GLX and automatically falls back to the XRender profile on VMs or
drivers without a usable GLX compositor. If neither backend initializes,
`stage3-picom.sh` restores XFCE's built-in compositor instead of leaving an
uncomposited session.
