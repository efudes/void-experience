# Changelog

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
- Added Celluloid and Thunar Space preview through GNOME Sushi.
- Added idempotent apply, validation, benchmark and recoverable rollback tools.
- Reworked the workstation prototype into a portable public installer:
  dynamic XRandR output discovery, reserved project panel IDs, no user paths,
  no machine snapshots, and explicit opt-in for shared MIME defaults.
