# Void Experience

Void Experience is a fast, reproducible XFCE/Xorg workstation profile for
Debian 13. It combines monitor-aware panels, compact workspace controls, Picom,
Rofi, window layouts with real gaps, a custom xfwm4 theme and a restrained
AMOLED-black/cyan visual language.

The installer is intentionally XFCE-scoped. It does not change GNOME
gsettings/dconf, GNOME Shell extensions, Mutter, GDM, shared GTK configuration,
the system icon default, or the display manager.

## Install

Start with Debian 13, log into an **XFCE on Xorg** session, then run:

```sh
git clone https://github.com/efudes/void-experience.git
cd void-experience
./install.sh
```

The installer first shows an optional-software checklist. Core XFCE, window
management and MP3/video support remain mandatory. For automation:

```sh
./install.sh --extras=steam,lutris
```

The optional `void-zsh` choice reproduces the project shell: Starship prompt,
Zoxide, FZF-oriented tools, modern aliases, autosuggestions, syntax
highlighting and the bundled JetBrainsMono Nerd Font. It requires a second,
literal confirmation before any shell file is changed. Changing the login
shell is a third, separate opt-in.

That is the only installation script. It:

1. shows a package checklist and the exact commands before privilege elevation;
2. creates a complete timestamped user-config backup;
3. detects active monitors instead of assuming connector names or coordinates;
4. applies every XFCE-only component idempotently;
5. prints the matching check and rollback commands.

Preview without changing anything:

```sh
./install.sh --dry-run
```

If all packages are already installed:

```sh
./install.sh --skip-packages
```

Celluloid is installed, but shared audio/video MIME defaults are left unchanged
by default. To opt in explicitly:

```sh
./install.sh --shared-media-defaults
```

That last option affects applications opened from both XFCE and GNOME because
freedesktop MIME associations are user-wide.

## What is included

- one 36 px top panel per active monitor;
- per-monitor Window Buttons filtering;
- primary-panel tray and custom geometric XKB indicator;
- four workspaces and compact pager;
- Picom 12.5 profile with VSync, 10 px floating corners and light shadows;
- Rofi launcher on `Super+R`;
- window-layout popup on `Super+Z`, direct layouts and 8 px gaps;
- Kitty on `Super+T`, Thunar on `Super+E`, lock on `Super+L`;
- show/restore desktop on `Super+D`;
- Flameshot on `Print` and XFCE Screenshooter on `Shift+Print`;
- lightweight Clipman clipboard history on `Super+V`;
- Celluloid and Thunar Space preview through Sushi;
- XFCE screensaver styling and compact native Alt+Tab;
- monitor-hotplug guard that regenerates panels from the current XRandR state.
- user-local guard for Debian 13's pre-upstream-fix xfwm4/Picom NULL lookup bug.
- unified label-free XFCE desktop icons with Papirus-Dark fallback.
- optional, rollback-safe Void Zsh profile and `ani-cli` package choice.

See [DESIGN.md](DESIGN.md) for the visual system and complete shortcut map.
See [VM-TEST.md](VM-TEST.md) for the clean-machine acceptance procedure.

## Validate

```sh
./scripts/check.sh
./scripts/benchmark.sh
./scripts/test-portability.sh
```

The check verifies required components, compositor exclusivity, XFCE-only
autostarts, panels, shortcuts, media preview and theme integration.
`test-portability.sh` uses a temporary HOME and mocked X11 services to verify
file-level apply idempotency, primary-monitor ordering and rollback semantics.

## Roll back

The installer prints its backup ID. Restore it from an XFCE session:

```sh
./scripts/rollback.sh YYYYMMDD-HHMMSS
```

When no ID is supplied, rollback uses the most recent install marker. Current
post-install configuration is moved into a recoverable directory inside the
backup before the baseline is restored. Packages are deliberately retained.

## GNOME isolation

Project autostarts contain `OnlyShowIn=XFCE;`; the session wrapper is read only
by XFCE; appearance is written only to XFCE's `xsettings` channel; panels and
shortcuts live in XFCE `xfconf`; Picom exits outside XFCE/X11. No GDM or GNOME
configuration is written.

The optional `--shared-media-defaults` switch is the sole documented exception,
and is never enabled implicitly.

## Known limitations

- XFCE's XKB and legacy tray plugins are kept on the primary panel because the
  Debian builds do not behave reliably as multiple simultaneous instances.
- Standard Window Buttons provide reliable monitor filtering; Docklike 0.4.3
  does not expose an equivalent verified filter.
- xfwm4 cannot provide a GNOME Tiling Assistant drag popup without replacing
  the window manager or adding a heavier daemon. Void Layout uses a fast Rofi
  chooser and direct shortcuts instead.
- Native xfwm4 Alt+Tab may be painted on every monitor. Avoiding that requires
  carrying an xfwm4 patch, which this project deliberately does not do.
- Wallpaper files are not downloaded. Put `space-dark.jpg` and/or
  `black-leather.jpg` in `~/Pictures/Void-Experience/`.

## Screenshots

Screenshots will be added after final multi-machine validation.

## License

GPL-3.0-or-later. The GTK layer inherits Arc-Dark; see
[NOTICE](NOTICE) for attribution.
