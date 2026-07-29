# Void Experience design

## Principles

1. Responsiveness
2. Reliability
3. Usability
4. Visual consistency
5. Decoration

## Palette

- Deep background: `#050608`
- Surface: `#0B0E11`
- Elevated surface: `#11161A`
- Foreground: `#E6F2F2`
- Muted foreground: `#91A3A6`
- Cyan accent: `#42D9D0`
- Secondary turquoise: `#2AAFA9`

Large cyan surfaces and strong gradients are avoided.

## Interaction

- Four stable workspaces
- `Super+R`: Rofi
- `Super+T`: Kitty
- `Super+E`: Thunar
- `Super+L`: lock screen
- `Super+D`: toggle the desktop and restore windows
- `Super+1..4`: select workspace
- `Super+Shift+1..4`: move active window
- `Super+Ctrl+Left/Right`: adjacent workspace
- `Super+Left/Right`: left/right half
- `Super+Up`: maximize
- `Super+Alt+Left/Right`: left/right third
- `Super+Shift+Left/Right`: left/right two-thirds
- `Super+Z`: visual layout grid
- `Print`: interactive Flameshot capture
- `Shift+Print`: XFCE Screenshooter
- `Super+V`: clipboard history

## Panels

Height is 36 px. The installer detects active XRandR outputs and creates a
matching top panel on each one. Standard Window Buttons filter other monitors.
The original panel profile is exported before the active list is replaced.
Tray and XKB remain single-instance components on the primary panel.

## Compositing

Picom is the only compositor in XFCE. The baseline uses GLX, VSync, damage
tracking, 10 px floating-window corners, restrained shadows, and no blur.
Fullscreen and maximized windows deliberately lose corners and shadows.

## GNOME boundary

No GNOME gsettings/dconf, Shell extensions, Mutter, session, GDM, shared GTK CSS,
system themes, icon defaults, or cursor defaults are modified.
