# Void Experience VM acceptance test

Run this on a disposable Debian 13 VM before merging the release branch.

## Suggested matrix

1. One virtual monitor, default virtual GPU.
2. Two virtual monitors with the second output marked primary.
3. GLX enabled.
4. GLX unavailable or forced to fail, exercising the XRender fallback.

## Clean installation

1. Install Debian 13 with GDM, GNOME and XFCE/Xorg.
2. Log into XFCE/Xorg.
3. Clone the repository into an arbitrary user and arbitrary directory.
4. Run `./install.sh --dry-run`.
5. Run `./install.sh`, selecting no optional Flatpak applications.
6. Save the printed backup ID.
7. Log out and back into XFCE.
8. Run:

   ```sh
   ./scripts/check.sh
   ./scripts/benchmark.sh
   ./scripts/test-portability.sh
   ```

Expected:

- one panel per active monitor;
- tray and XKB indicator on the XRandR primary monitor;
- one Picom process using GLX or the documented XRender fallback;
- no simultaneous xfwm4 compositor;
- Noto Sans resolves without font fallback;
- all launchers and autostarts contain the VM user's HOME, not a source-machine
  path.

## Repeat apply

Run twice:

```sh
./scripts/apply.sh --all
./scripts/apply.sh --all
```

Expected:

- no duplicate Kitty include, Thunar action, autostart, panel or helper;
- one Picom, one Clipman and one panel watcher;
- panel composition remains identical after the second run.

## Monitor changes

1. Start with one output.
2. Attach the second output and wait up to ten seconds.
3. Mark the second output primary.
4. Disconnect it again.

Expected:

- panels regenerate once per real connector change;
- primary-only tray/XKB moves to the current primary;
- maximized work areas respect the panel on each output;
- no EDID/RandR log storm and no repeated panel restarts.

## Real rollback

Create a small pre-install marker in the XFCE configuration and on the Desktop
before installation. After validating the installed session:

```sh
./scripts/rollback.sh BACKUP_ID
```

Then log out immediately and log back into XFCE.

Expected:

- the original panel profile and marker files return;
- Void Experience helpers and desktop launchers are absent unless they existed
  in the baseline;
- files displaced during rollback remain recoverable inside the backup;
- packages remain installed by design;
- GNOME and GDM remain available and unchanged.

## GNOME isolation

Log into GNOME through GDM without changing the display manager.

Expected:

- Picom, `xfce4-panel` and `void-panel-watch` are absent;
- GNOME theme, extensions, cursor and panel appearance are unchanged;
- XFCE-only desktop launchers do not appear on the GNOME desktop.

The temporary-HOME test proves file-level idempotency and restore ordering. It
does not replace this live-session acceptance test.
