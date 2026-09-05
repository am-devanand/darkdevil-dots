#!/usr/bin/env bash
# DarkDevil Dots - CachyOS / Arch / Hyprland + Caelestia installer
# Copy-based (JaKooLit style). Safe to move repo after install.
set -euo pipefail
DOTDIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M)"

msg() { echo "==> $*"; }

msg "Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for d in hypr caelestia quickshell/caelestia foot fish btop fastfetch; do
  [ -e "$HOME/.config/$d" ] && cp -a "$HOME/.config/$d" "$BACKUP_DIR/" || true
done
[ -f "$HOME/.config/starship.toml" ] && cp -a "$HOME/.config/starship.toml" "$BACKUP_DIR/" || true

msg "Installing system packages (pacman)"
if [ -f "$DOTDIR/packages-pacman.txt" ]; then
  sudo pacman -S --needed - < "$DOTDIR/packages-pacman.txt" || msg "pacman step had warnings, continuing"
fi

msg "Installing AUR packages (yay)"
if ! command -v yay >/dev/null 2>&1; then
  msg "yay not found, install yay first: sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si)"
  exit 1
fi
# Core DarkDevil/Caelestia stack - always ensure these
yay -S --needed quickshell-git caelestia-shell caelestia-cli papirus-icon-theme adw-gtk-theme qtengine-git ttf-jetbrains-mono-nerd || true
if [ -f "$DOTDIR/packages-aur.txt" ]; then
  yay -S --needed - < "$DOTDIR/packages-aur.txt" || msg "aur step had warnings, continuing"
fi

msg "Copying configs (copy, not symlink)"
mkdir -p ~/.config
cp -a "$DOTDIR/hypr" ~/.config/hypr-tmp-merge 2>/dev/null || true
# hypr: repo stores real files, ~/.config/hypr is symlink to ~/caelestia/hypr on old installs
if [ -L ~/.config/hypr ]; then
  rm ~/.config/hypr
fi
mkdir -p ~/.config/hypr
cp -a "$DOTDIR/hypr/." ~/.config/hypr/
rm -rf ~/.config/hypr-tmp-merge || true

mkdir -p ~/.config/caelestia/monitors
cp -a "$DOTDIR/caelestia/shell.json" ~/.config/caelestia/shell.json
cp -a "$DOTDIR/caelestia/cli.json" ~/.config/caelestia/cli.json
cp -a "$DOTDIR/caelestia/sidebar-waybar.json" ~/.config/caelestia/sidebar-waybar.json
# hypr-user.conf is sourced LAST by hyprland.conf - DarkDevil login hooks (auto-open notif dock)
cp -a "$DOTDIR/caelestia/hypr-user.conf" ~/.config/caelestia/hypr-user.conf
# monitors are per-machine - only copy if missing
for m in "$DOTDIR"/caelestia/monitors/*; do
  bn=$(basename "$m")
  [ -e "$HOME/.config/caelestia/monitors/$bn" ] || cp -a "$m" "$HOME/.config/caelestia/monitors/"
done

for app in foot fish btop fastfetch; do
  [ -d "$DOTDIR/$app" ] && { mkdir -p ~/.config/$app; cp -a "$DOTDIR/$app/." ~/.config/$app/; }
done
[ -f "$DOTDIR/starship.toml" ] && cp -a "$DOTDIR/starship.toml" ~/.config/starship.toml

mkdir -p ~/Pictures/wallpapers
[ -d "$DOTDIR/wallpapers" ] && cp -an "$DOTDIR/wallpapers/." ~/Pictures/wallpapers/ || true

# QML overrides (notification cards, dashboard, etc.)
QS_DIR="$HOME/.config/quickshell/caelestia/modules"
QS_BACKUP="$HOME/.config/quickshell/pre-darkdevil-$(date +%Y%m%d)"
if [ -d "$DOTDIR/quickshell-overrides" ]; then
  msg "Applying QML overrides"
  mkdir -p "$QS_BACKUP"
  for module in notifications bar drawers dashboard; do
    [ -d "$QS_DIR/$module" ] && cp -a "$QS_DIR/$module" "$QS_BACKUP/" 2>/dev/null || true
  done
  for module in notifications bar drawers dashboard; do
    if [ -d "$DOTDIR/quickshell-overrides/$module" ]; then
      mkdir -p "$QS_DIR/$module"
      cp -a "$DOTDIR/quickshell-overrides/$module/." "$QS_DIR/$module/"
    fi
  done
fi

msg "Done. Backup at $BACKUP_DIR"
msg "Restart shell: caelestia shell -k && sleep 1 && caelestia shell -d"
msg "If Hyprland fails: restore from $BACKUP_DIR"
