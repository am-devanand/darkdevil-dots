#!/usr/bin/env bash
# DarkDevil theme - dark-first everforest. Re-run on any machine to match laptop 1.
# Generated files (hypr/scheme/current.lua, gtk, btop, fuzzel) are derived from this - don't hand-edit them.
set -euo pipefail
caelestia scheme set -n everforest -m dark -v fidelity 2>&1 | grep -v "brave/policies" || true
echo "Theme: everforest dark fidelity applied (ignore Brave /etc warning - needs sudo, harmless)"
caelestia scheme get | head -6
