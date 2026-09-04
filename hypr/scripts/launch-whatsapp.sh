#!/usr/bin/env bash
# launch-whatsapp.sh — Copilot key → WhatsApp Web (Hyprland)
# Smart toggle: if WhatsApp is already open → focus it, else launch brave --app
# Works with Brave (installed) and falls back to xdg-open
set -e

URL="https://web.whatsapp.com"
APP_URL="--app=${URL}"

# Try to find existing WhatsApp window via hyprctl clients JSON
if command -v jq >/dev/null 2>&1 && command -v hyprctl >/dev/null 2>&1; then
    # Search for window with class/title matching whatsapp (case-insensitive)
    WIN=$(hyprctl clients -j 2>/dev/null | jq -r '
        .[] 
        | select(
            (.class | test("(?i)whatsapp"; "i")) or
            (.title | test("(?i)whatsapp"; "i")) or
            (.initialTitle | test("(?i)whatsapp"; "i"))
          )
        | .address
        | select(. != null)
        ' | head -n1)

    if [[ -n "$WIN" && "$WIN" != "null" ]]; then
        # Focus existing window
        hyprctl dispatch focuswindow address:${WIN} 2>/dev/null
        # also bring to current workspace if in special or hidden
        notify-send -u low -i whatsapp -a "WhatsApp" "WhatsApp Web" "Focused existing window" 2>/dev/null || true
        exit 0
    fi

    # Also check for any brave window with whatsapp URL in title (brave app mode)
    WIN2=$(hyprctl clients -j 2>/dev/null | jq -r '
        .[]
        | select(.title | test("WhatsApp"; "i"))
        | .address
        ' | head -n1)
    if [[ -n "$WIN2" && "$WIN2" != "null" ]]; then
        hyprctl dispatch focuswindow address:${WIN2} 2>/dev/null
        exit 0
    fi
fi

# No existing window → launch new one
notify-send -u low -i whatsapp -a "WhatsApp" "WhatsApp Web" "Launching..." 2>/dev/null || true

if command -v brave >/dev/null 2>&1; then
    # brave --app creates a clean app-mode window (no tabs/bookmarks)
    # app2unit keeps it in systemd scope for Hyprland
    if command -v app2unit >/dev/null 2>&1; then
        app2unit -- brave "${APP_URL}" >/dev/null 2>&1 &
    else
        brave "${APP_URL}" >/dev/null 2>&1 &
    fi
elif command -v firefox >/dev/null 2>&1; then
    # Firefox SSB fallback
    firefox "${URL}" >/dev/null 2>&1 &
else
    xdg-open "${URL}" >/dev/null 2>&1 &
fi

# disown so hyprland doesn't track the shell
disown 2>/dev/null || true
