-- hyprland.lua — Hyprland config entry point (replaces hyprland.conf)
-- Modules are required in dependency order; each registers its own hl.* calls.

require("modules.colors")     -- must load first: colors.lua also exposes raw palette values via vars/colors
require("modules.vars")       -- all shared variables (paths, keybind combos, toggles)
require("modules.env")        -- environment variables (exec-once style)
require("modules.monitors")   -- monitor configuration
require("modules.general")    -- general section
require("modules.input")      -- input / keyboard / mouse
require("modules.misc")       -- misc section
require("modules.decoration") -- decoration / blur / shadows
require("modules.group")      -- window groups
require("modules.animations") -- animation curves
require("modules.scrolling")  -- scroll curves
require("modules.gestures")   -- touchpad gestures
require("modules.execs")      -- hyprland.start / config.reloaded hooks
require("modules.rules")      -- window rules
require("modules.keybinds")   -- keybinds (submap = global)
