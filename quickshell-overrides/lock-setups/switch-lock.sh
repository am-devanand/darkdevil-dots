#!/usr/bin/env bash
# switch-lock.sh 1|2 — swap between saved lock screen setups.
#   1 = glassy dashboard era (stock layout + glass/monochrome)
#   2 = DarkDevil Editorial hero (current)
# Current live lock is backed up before every switch.
set -euo pipefail
SETUPS="$(cd "$(dirname "$0")" && pwd)"
QS_DIR="$HOME/.config/quickshell/caelestia/modules/lock"

case "${1:-}" in
  1|2) ;;
  *) echo "usage: $(basename "$0") 1|2"; exit 1 ;;
esac

[ -d "$SETUPS/setup-$1" ] || { echo "setup-$1 not found in $SETUPS"; exit 1; }
[ -d "$QS_DIR" ] || { echo "live lock dir missing: $QS_DIR"; exit 1; }

BACKUP="$HOME/.config/quickshell/pre-darkdevil-$(date +%Y%m%d-%H%M)-lock"
mkdir -p "$BACKUP"
cp -a "$QS_DIR" "$BACKUP/"
cp -a "$SETUPS/setup-$1/." "$QS_DIR/"

echo "Switched to lock setup $1."
echo "Previous live lock saved at $BACKUP"
echo "Restart shell: caelestia shell -k && sleep 1 && caelestia shell -d"
