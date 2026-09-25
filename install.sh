#!/usr/bin/env bash
# DarkDevil Dots - CachyOS / Arch / Hyprland + Caelestia installer
# Copy-based (JaKooLit style). Safe to move repo after install.
set -euo pipefail
DOTDIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M)"

msg() { echo "==> $*"; }

msg "Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for d in hypr caelestia quickshell/caelestia foot fish btop fastfetch opencode; do
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
# Core stack - always ensure these even if the package lists were trimmed.
# Stable quickshell comes from packages-pacman.txt; never quickshell-git.
yay -S --needed caelestia-shell-git caelestia-cli || true
if [ -f "$DOTDIR/packages-aur.txt" ]; then
  grep -v '^[[:space:]]*#' "$DOTDIR/packages-aur.txt" | sed 's/[[:space:]].*//' | grep -v '^[[:space:]]*$' | yay -S --needed - || msg "aur step had warnings, continuing"
fi

msg "Provisioning base shell (package copy, only if missing)"
QS_BASE_SRC="/etc/xdg/quickshell/caelestia"
QS_BASE_DST="$HOME/.config/quickshell/caelestia"
if [ ! -d "$QS_BASE_DST/modules" ]; then
  if [ -d "$QS_BASE_SRC" ]; then
    mkdir -p "$HOME/.config/quickshell"
    cp -a "$QS_BASE_SRC" "$QS_BASE_DST"
  else
    msg "WARNING: $QS_BASE_SRC missing - is caelestia-shell-git installed?"
  fi
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
# opencode CLI config (themes, keybinds) - no-clobber so live plugins survive
[ -d "$DOTDIR/opencode" ] && { mkdir -p ~/.config/opencode; cp -an "$DOTDIR/opencode/." ~/.config/opencode/; }

# System network tuning (Wi-Fi powersave off, no scan MAC randomization)
if [ -d "$DOTDIR/system/etc/NetworkManager/conf.d" ]; then
  sudo mkdir -p /etc/NetworkManager/conf.d
  sudo cp -a "$DOTDIR/system/etc/NetworkManager/conf.d/." /etc/NetworkManager/conf.d/
  sudo chmod 644 /etc/NetworkManager/conf.d/* 2>/dev/null || true
fi

# Wallpapers travel out-of-band (1GB+, gitignored). Ship one default so a
# fresh machine still has a wallpaper on first boot.
mkdir -p ~/Pictures/wallpapers
[ -d "$DOTDIR/wallpapers" ] && cp -an "$DOTDIR/wallpapers/." ~/Pictures/wallpapers/ || true
if [ -z "$(ls -A ~/Pictures/wallpapers 2>/dev/null)" ] && [ -d "$DOTDIR/wallpapers-default" ]; then
  cp -an "$DOTDIR/wallpapers-default/." ~/Pictures/wallpapers/
fi

# QML overrides - single source of truth is quickshell-overrides/.
if [ -f "$DOTDIR/quickshell-overrides/apply-overrides.sh" ]; then
  msg "Applying QML overrides"
  bash "$DOTDIR/quickshell-overrides/apply-overrides.sh"
else
  msg "WARNING: apply-overrides.sh missing, skipping QML overrides"
fi

msg "Done. Backup at $BACKUP_DIR"
msg "Set wallpaper: caelestia wallpaper -f ~/Pictures/wallpapers/<file> (or -r for random)"
msg "Restart shell: caelestia shell -k && sleep 1 && caelestia shell -d"
msg "If Hyprland fails: restore from $BACKUP_DIR"
