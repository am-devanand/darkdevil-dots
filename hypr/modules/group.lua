-- group.lua — window groups + groupbar (replaces hyprland/group.conf)
local colors = require("modules.colors")
local vars   = require("modules.vars")

hl.config({
    group = {
        col = {
            border_active          = vars.activeWindowBorderColour,
            border_inactive        = vars.inactiveWindowBorderColour,
            border_locked_active   = vars.activeWindowBorderColour,
            border_locked_inactive = vars.inactiveWindowBorderColour,
        },

        groupbar = {
            font_family              = "JetBrains Mono NF",
            font_size                = 15,
            gradients                = true,
            gradient_round_only_edges = false,
            gradient_rounding        = 5,
            height                   = 25,
            indicator_height         = 0,
            gaps_in                  = 3,
            gaps_out                 = 3,

            text_color = colors.rgb("onPrimary"),
            col = {
                active          = colors.rgba("primary", "d4"),
                inactive        = colors.rgba("outline", "d4"),
                locked_active   = colors.rgba("primary", "d4"),
                locked_inactive = colors.rgba("secondary", "d4"),
            },
        },
    },
})