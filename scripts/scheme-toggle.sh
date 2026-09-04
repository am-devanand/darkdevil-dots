#!/usr/bin/env bash
# scheme-toggle.sh — quick scheme controls for DarkDevil
# Usage:
#   scheme-toggle.sh mode       → toggle dark ↔ light
#   scheme-toggle.sh variant    → cycle variant (tonalspot → vibrant → expressive → ...)
#   scheme-toggle.sh scheme     → cycle named scheme (dynamic → catppuccin → dracula → ...)
#   scheme-toggle.sh random     → random wallpaper + auto scheme
#
# Stays in dynamic mode for wallpaper-matched colors.
# Only changes mode/variant/flavour — never forces a static scheme unless explicitly asked.

set -euo pipefail

SCHEME_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia"
SCHEME_FILE="$SCHEME_DIR/scheme.json"

# All available variants in a fixed order
VARIANTS=(tonalspot vibrant expressive fidelity fruitsalad monochrome neutral rainbow content)

# Named schemes (non-dynamic ones you might want to cycle through)
NAMES=(dynamic catppuccin dracula everforest gruvbox nord onedark rosepine tokyonight solarized)

# --- helpers ---
get_field() {
    python3 -c "import json; d=json.load(open('$SCHEME_FILE')); print(d.get('$1',''))"
}

set_field() {
    local field="$1" value="$2"
    python3 -c "
import json, sys
f = open('$SCHEME_FILE', 'r+')
d = json.load(f)
d['$field'] = '$value'
f.seek(0); f.truncate()
json.dump(d, f, indent=4)
"
}

cycle_next() {
    # $1 = current value, $2... = list of options
    local current="$1"; shift
    local arr=("$@")
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" == "$current" ]]; then
            echo "${arr[$(( (i + 1) % ${#arr[@]} ))]}"
            return
        fi
    done
    echo "${arr[0]}"  # fallback: first item
}

notify() {
    notify-send -u low -i preferences-desktop-theme-symbolic "Theme" "$1" -a "DarkDevil" 2>/dev/null || true
}

# --- actions ---
toggle_mode() {
    local current
    current=$(get_field "mode")
    if [[ "$current" == "dark" ]]; then
        set_field "mode" "light"
        notify "☀ Light mode"
    else
        set_field "mode" "dark"
        notify "🌙 Dark mode"
    fi
    # Reapply with updated mode
    caelestia scheme set -m "$(get_field mode)"
}

cycle_variant() {
    local current
    current=$(get_field "variant")
    local next
    next=$(cycle_next "$current" "${VARIANTS[@]}")
    set_field "variant" "$next"
    notify "Variant: $next"
    caelestia scheme set -v "$next"
}

cycle_scheme() {
    local current
    current=$(get_field "name")
    local next
    next=$(cycle_next "$current" "${NAMES[@]}")
    set_field "name" "$next"
    notify "Scheme: $next"
    caelestia scheme set -n "$next"
}

random_wallpaper() {
    caelestia wallpaper -r
    notify "🎲 Random wallpaper"
}

# --- main ---
case "${1:-mode}" in
    mode)     toggle_mode ;;
    variant)  cycle_variant ;;
    scheme)   cycle_scheme ;;
    random)   random_wallpaper ;;
    *)        echo "Usage: $0 {mode|variant|scheme|random}" ;;
esac
