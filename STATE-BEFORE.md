# State before installation

Every installation records its own baseline under:

```text
~/desktop-backups/void-experience/YYYYMMDD-HHMMSS/
```

The snapshot preserves the original directory structure for XFCE, Picom, Rofi,
autostart, Kitty, Thunar, MIME associations and an existing Void Experience
theme. It also contains:

- `MANIFEST.txt` with timestamp, host, user and session type;
- `PRESENT.txt` listing paths that existed before installation;
- `panel-profile/xfce-panel.tar.bz2` when panel profile export is available.

No workstation-specific baseline or hostname is committed to this repository.
