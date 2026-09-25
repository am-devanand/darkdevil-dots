-- execs.lua — autostart + reload-time commands (replaces hyprland/execs.conf
-- and the two `exec =` lines from hyprland.conf)
local vars = require("modules.vars")
local HOME = os.getenv("HOME") or "/home/darkdevil"

-- exec-once -> hyprland.start
hl.on("hyprland.start", function()
    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. vars.cursorTheme .. "'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Location provider and night light
    hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
    hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Handy voice-to-text (hidden, SUPER+H toggles transcription)
    hl.exec_cmd("handy --start-hidden")

    -- Resize and move windows based on matches (e.g. pip)
    hl.exec_cmd("caelestia resizer -d")

    -- Start shell
    hl.exec_cmd("caelestia shell -d")

    -- DarkDevil: auto-open notification dock on login
    hl.exec_cmd("sleep 5 && caelestia shell drawers toggle sidebar")
end)

-- `exec =` (runs on every reload) -> config.reloaded
hl.on("config.reloaded", function()
    -- Ensure the active scheme exists (first run / stale current.conf)
    hl.exec_cmd("cp -L --no-preserve=mode --update=none " .. HOME .. "/.config/hypr/scheme/default.conf " .. HOME .. "/.config/hypr/scheme/current.conf")
    -- Maybe create the user config files
    hl.exec_cmd(HOME .. "/.config/hypr/scripts/configs.fish " .. HOME .. "/.config/caelestia")
    -- Reset to the global submap (was `exec = hyprctl dispatch submap global`)
    hl.dispatch(hl.dsp.submap("global"))
end)