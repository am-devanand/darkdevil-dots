# DarkDevil Dots

A version-controlled, reproducible Caelestia-based desktop environment for CachyOS + Hyprland.

## Install

```bash
git clone https://github.com/am-devanand/darkdevil-dots.git ~/.local/share/darkdevil
cd ~/.local/share/darkdevil
./install.sh
```

One command. Packages, configs, QML patches — all applied.

## What's inside

| Layer | What it controls | Files |
|-------|-----------------|-------|
| JSON | Theme, bar, sidebar, launcher, spacing, timeouts | `caelestia/shell.json` |
| Lua | Startup hooks, keybinds | `hypr/modules/*.lua` |
| QML | Notification cards, dashboard cards | `quickshell-overrides/` |
| Script | One-command deploy | `install.sh` |

## Key changes from stock Caelestia

- Dark-first everforest theme locked
- Right-side notification dock (Super+N)
- Auto-open notif dock on login
- Bar always visible, tray icons recoloured
- Launcher fuzzy search all categories
- Notification popups 4s, OSD 3s
- Lock screen uses wallpaper
- Tighter spacing, glass transparency
- Dashboard hover on, utilities hover off
- Notification + dashboard card borders

## After Caelestia updates

```bash
cd ~/.local/share/darkdevil
git pull
./install.sh
```

QML patches are re-applied automatically. Live QML is backed up to `~/.config/quickshell/pre-darkdevil-YYYYMMDD/`.

## Tech stack

- CachyOS (Arch-based)
- Hyprland (Wayland compositor)
- Caelestia Shell (Quickshell/QML)
- Caelestia CLI (Python)
- fish shell, foot terminal, starship prompt

## Credits

- [caelestia-dots/shell](https://github.com/caelestia-dots/shell) — desktop shell (GPL-3.0)
- [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) — base dotfiles (GPL-3.0)
- [JaKooLit](https://github.com/JaKooLit) — install model reference

## Fresh machine notes

- Wallpapers (1GB+) sync out-of-band (rsync/Syncthing). If `~/Pictures/wallpapers`
  is empty, install.sh drops in one default (`wallpapers-default/`) — set it with
  `caelestia wallpaper -f <file>` (scheme regenerates from the wallpaper).
- `hypr/scheme/current.lua` is a snapshot; caelestia rewrites it on wallpaper change.
- Lock screen variants are manual: `quickshell-overrides/lock-setups/switch-lock.sh 1|2`.
- Keybinds live in `hypr/hyprland/keybinds.conf` (+ `$kb*` vars in `hypr/variables.conf`).
- install.sh needs sudo (pacman + `/etc/NetworkManager/conf.d` Wi-Fi tuning).

## License

Your own configs: yours. Anything derived from Caelestia: GPL-3.0, notices preserved.
