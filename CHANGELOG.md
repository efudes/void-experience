# Changelog

## Package selector — 2026-07-28

- Split installation into a mandatory Debian core and an interactive checklist.
- Added opt-in Flathub choices for Steam, Lutris, Discord and PortProton.
- Kept third-party APT repositories and downloaded installer scripts out.
- Added an XFCE-only icon layer for unified label-free desktop icons.
- Corrected the optical baseline of right-side panel indicator images.
- Declared Noto, XDG, process, NetworkManager and GTK helper dependencies.
- Made primary-monitor selection explicit and corrected rollback restore order.
- Added Picom XRender fallback and xfwm compositor recovery for unsupported GPUs.
- Added temporary-HOME regression tests for one/two monitors, repeated apply and rollback.
- Replaced non-portable `$HOME` Desktop Entry commands with install-time templates.
- Added matching per-shortcut Downloads and Documents icons without changing
  the user's whitespace-only desktop labels.
- Added opt-in `ani-cli` and a doubly confirmed, backup-gated Void Zsh profile
  reproducing the workstation prompt, aliases, tools and Nerd Font.
- Fixed layouts for freshly opened maximized Kitty windows by sending
  fullscreen and maximize removals as valid separate EWMH requests.
- Added individually selectable CAVA, ncdu, duf, dust, lazygit, broot and Glow
  packages to the optional Debian software checklist.
- Added native xfwm4 close-window handling on `Super+W` while preserving
  `Alt+F4`.

## 0.1.0 — 2026-07-28

- Built the complete Void Experience XFCE/Xorg profile on Debian 13.
- Added monitor-aware 36 px panels with per-monitor task lists, a compact tray,
  network/audio controls, custom XKB runes, clock and session action.
- Added four-workspace navigation and direct window movement shortcuts.
- Added the user-local Void Experience xfwm4 and scoped GTK themes.
- Configured Picom as the sole XFCE compositor with VSync, restrained shadows,
  floating-window corners and fullscreen/maximized exclusions.
- Added Rofi launcher and multi-monitor active-window layouts with 8 px gaps.
- Added XFCE-only cursor propagation for native and Flatpak applications.
- Added styled XFCE lock screen, native Alt+Tab treatment and `Super+D`.
- Assigned Flameshot to `Print` and XFCE Screenshooter to `Shift+Print`.
- Corrected the optical vertical alignment of Window Buttons labels.
- Added XFCE-only Clipman clipboard history on `Super+V`.
- Replaced aggressive XRandR panel polling with DRM connector status checks to
  prevent EDID/xfwm4 event storms.
- Added a user-local runtime equivalent of upstream xfwm4 commit `69a16352` for
  the external-compositor NULL hash bug present in Debian 13's xfwm4 4.20.0.
- Added Celluloid and Thunar Space preview through GNOME Sushi.
- Added idempotent apply, validation, benchmark and recoverable rollback tools.
- Reworked the workstation prototype into a portable public installer:
  dynamic XRandR output discovery, reserved project panel IDs, no user paths,
  no machine snapshots, and explicit opt-in for shared MIME defaults.
