-- rules.lua — window / workspace / layer rules (replaces hyprland/rules.conf)
local vars = require("modules.vars")

-------------------------------------------------------
-- Window rules
-------------------------------------------------------
hl.window_rule({
    name  = "default-opacity",
    match = { fullscreen = false },
    opacity = vars.windowOpacity .. " override",
})

hl.window_rule({
    name  = "opaque-native-tp",
    match = { class = "foot|equibop|org\\.quickshell|imv|swappy" },
    opaque = true, -- they use native transparency or we want them opaque
})
hl.window_rule({
    name  = "center-floating",
    match = { float = true, xwayland = false },
    center = true, -- center all floating windows (not xwayland, popups)
})

-- Float
hl.window_rule({ match = { class = "guifetch" }, float = true })                                   -- FlafyDev/guifetch
hl.window_rule({ match = { class = "yad" }, float = true })
hl.window_rule({ match = { class = "zenity" }, float = true })
hl.window_rule({ match = { class = "wev" }, float = true })
hl.window_rule({ match = { class = "org\\.gnome\\.FileRoller" }, float = true })
hl.window_rule({ match = { class = "file-roller" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, float = true })
hl.window_rule({ match = { class = "com\\.github\\.GradienceTeam\\.Gradience" }, float = true })
hl.window_rule({ match = { class = "feh" }, float = true })
hl.window_rule({ match = { class = "imv" }, float = true })
hl.window_rule({ match = { class = "system-config-printer" }, float = true })
hl.window_rule({ match = { class = "org\\.quickshell" }, float = true })

-- Float, resize and center
hl.window_rule({ match = { class = "foot", title = "nmtui" }, float = true, size = "60% 70%", center = true })
hl.window_rule({ match = { class = "org\\.gnome\\.Settings" }, float = true, size = "70% 80%", center = true })
hl.window_rule({ match = { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" }, float = true, size = "60% 70%", center = true })
hl.window_rule({ match = { class = "nwg-look" }, float = true, size = "50% 60%", center = true })

-- Special workspaces
hl.window_rule({ match = { class = "btop" }, workspace = "special:sysmon" })
hl.window_rule({ match = { class = "feishin|Spotify|Supersonic|Cider|com\\.github\\.th_ch\\.youtube_music|Plexamp" }, workspace = "special:music" })
hl.window_rule({ match = { initial_title = "Spotify( Free)?" }, workspace = "special:music" }) -- Spotify wayland: no class
hl.window_rule({ match = { class = "discord|equibop|vesktop|whatsapp" }, workspace = "special:communication" })
hl.window_rule({ match = { class = "Todoist" }, workspace = "special:todo" })

-- Dialogs
hl.window_rule({ match = { title = "(Select|Open)( a)? (File|Folder)(s)?" }, float = true })
hl.window_rule({ match = { title = "File (Operation|Upload)( Progress)?" }, float = true })
hl.window_rule({ match = { title = ".* Properties" }, float = true })
hl.window_rule({ match = { title = "Export Image as PNG" }, float = true })
hl.window_rule({ match = { title = "GIMP Crash Debug" }, float = true })
hl.window_rule({ match = { title = "Save As" }, float = true })
hl.window_rule({ match = { title = "Library" }, float = true })

-- Picture in picture (resize/move done via the caelestia resizer script)
hl.window_rule({ match = { title = "Picture(-| )in(-| )[Pp]icture" }, move = "100%-w-2% 100%-w-3%", keep_aspect_ratio = true, float = true, pin = true })

-- Creative software
hl.window_rule({ match = { class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" }, opaque = true })

-- Ueberzugpp
hl.window_rule({ match = { class = "^(ueberzugpp_.*)$" }, float = true, no_initial_focus = true })

-- Steam
hl.window_rule({ match = { class = "steam" }, rounding = 10 })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, float = true })

-- Games (Steam, Lutris/Wine, Gamescope)
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, opaque = true })
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, immediate = true })     -- tearing for games
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, idle_inhibit = "always" })

-- Minecraft launcher consoles
hl.window_rule({ match = { class = "com-atlauncher-App", title = "ATLauncher Console" }, float = true })
hl.window_rule({ match = { class = "PandoraLauncher", title = "Minecraft Game Output" }, float = true })

-- Autodesk Fusion 360
hl.window_rule({ match = { class = "fusion360\\.exe", title = "Fusion360|(Marking Menu)" }, no_blur = true })

-- Ugh xwayland popups
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_dim = true })
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_shadow = true })
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, rounding = 10 })

-------------------------------------------------------
-- Workspace rules
-------------------------------------------------------
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = vars.singleWindowGapsOut })

-------------------------------------------------------
-- Layer rules
-------------------------------------------------------
hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })       -- colour picker out animation
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })    -- wlogout
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })        -- slurp
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" })

-- Fuzzel
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%" })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true })

-- Shell
hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)" }, animation = "fade" })