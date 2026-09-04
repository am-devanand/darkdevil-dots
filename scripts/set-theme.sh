#!/usr/bin/env bash
# DarkDevil theme - dynamic (wallpaper-matched colors). Re-run on any machine.
set -euo pipefail
caelestia scheme set -n dynamic -m dark 2>&1 | grep -v "brave/policies" || true
echo "Theme: dynamic dark (wallpaper-matched colors)"
caelestia scheme get | head -6
