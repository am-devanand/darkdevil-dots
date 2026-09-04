#!/usr/bin/env bash
# DarkDevil QML overrides - apply after yay updates
set -euo pipefail
OVERRIDES="$(cd "$(dirname "$0")" && pwd)"
QS_DIR="$HOME/.config/quickshell/caelestia/modules"
BACKUP="$HOME/.config/quickshell/pre-darkdevil-$(date +%Y%m%d)"

msg() { echo "==> $*"; }

msg "Backing up live QML to $BACKUP"
mkdir -p "$BACKUP"
cp -a "$QS_DIR/notifications" "$BACKUP/" 2>/dev/null || true
cp -a "$QS_DIR/bar" "$BACKUP/" 2>/dev/null || true
cp -a "$QS_DIR/drawers" "$BACKUP/" 2>/dev/null || true

for module in notifications bar drawers dashboard; do
  if [ -d "$OVERRIDES/$module" ]; then
    msg "Applying $module overrides"
    mkdir -p "$QS_DIR/$module"
    cp -a "$OVERRIDES/$module/." "$QS_DIR/$module/"
  fi
done

msg "Done. Restart shell: caelestia shell -k && sleep 1 && caelestia shell -d"
