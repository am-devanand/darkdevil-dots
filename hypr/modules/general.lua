-- general.lua — general + dwindle (replaces hyprland/general.conf)
local vars = require("modules.vars")

hl.config({
    general = {
        layout = "dwindle",

        allow_tearing = false, -- allows the `immediate` window rule to work

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

        col = {
            active_border   = vars.activeWindowBorderColour,
            inactive_border = vars.inactiveWindowBorderColour,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },
})