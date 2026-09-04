# DarkDevil Dots

CachyOS + Hyprland + Caelestia-based personal setup. Replicate same setup on any laptop.

Derived from / inspired by:
- `caelestia-dots/shell` (GPL-3.0) - desktop shell
- `caelestia-dots/caelestia` (GPL-3.0) - base dotfiles
- JaKooLit Arch-Hyprland install model (copy-based)

This repo does NOT rename internal `caelestia` IDs. Display brand is DarkDevil,
internals stay `caelestia` so `caelestia-cli`, `qs -c caelestia`, AUR updates keep working.

## Restore as-it-is (laptop 2 / fresh install)

```bash
git clone <your-url> ~/.local/share/darkdevil
cd ~/.local/share/darkdevil
./install.sh
hyprctl reload
caelestia shell -d
```

Backup of pre-change laptop 1 is NOT in this repo. Keep
`DarkDevil-BACKUP-pre-change-2026-09-04.tar.gz` on USB + private remote.

## Daily workflow (laptop 1)

```bash
# before risky tweak
cp ~/.config/caelestia/shell.json ~/shell.json.$(date +%H%M)

# after good tweak - version it
cp ~/.config/caelestia/shell.json ~/darkdevil-dots/caelestia/shell.json
cp ~/caelestia/hypr/hyprland/* ~/darkdevil-dots/hypr/hyprland/ 2>/dev/null || cp -aL ~/.config/hypr/. ~/darkdevil-dots/hypr/
cd ~/darkdevil-dots && git status && git add -A && git commit -m "tweak: ..."
git push
```

## Layout

- `hypr/` -> `~/.config/hypr`
- `caelestia/shell.json cli.json` -> `~/.config/caelestia/`
- `foot/ fish/ btop/ fastfetch/ starship.toml` -> `~/.config/`
- `quickshell-overrides/` -> only your QML patches, not full shell (AUR owns full shell)
- `wallpapers/` -> `~/Pictures/wallpapers`
- `packages-pacman.txt packages-aur.txt` -> reproducible packages

## License

Your own configs: yours. Anything copied from Caelestia: GPL-3.0, keep notices.
