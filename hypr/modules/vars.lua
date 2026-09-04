--[[
    vars.lua — shared variables (replaces variables.conf).
    Returned table is required by every other module.

    User overrides in ~/.config/caelestia/hypr-vars.conf are applied on top
    (plain `$name = value` pairs). To override a colour, edit modules/colors.lua
    or set the full string here instead.
--]]
local colors = require("modules.colors")
local HOME   = os.getenv("HOME") or "/home/darkdevil"

local vars = {
    -- Apps
    terminal     = "foot",
    browser      = "zen-browser",
    editor       = "codium",
    fileExplorer = "thunar",

    -- Touchpad
    touchpadDisableTyping = true,
    touchpadScrollFactor  = 0.3,
    workspaceSwipeFingers = 4,
    gestureFingers        = 3,
    gestureFingersMore    = 4,

    -- Blur
    blurEnabled      = true,
    blurSpecialWs    = false,
    blurPopups       = true,
    blurInputMethods = true,
    blurSize         = 8,
    blurPasses       = 2,
    blurXray         = false,

    -- Shadow
    shadowEnabled     = true,
    shadowRange       = 20,
    shadowRenderPower = 3,
    shadowColour      = colors.rgba("surface", "d4"),

    -- Gaps
    workspaceGaps       = 20,
    windowGapsIn        = 5,
    windowGapsOut       = 10,
    singleWindowGapsOut = 20,

    -- Window styling
    windowOpacity              = 0.95,
    windowRounding             = 15,
    windowBorderSize           = 1,
    activeWindowBorderColour   = colors.rgba("primary", "e6"),
    inactiveWindowBorderColour = colors.rgba("onSurfaceVariant", "11"),

    -- Misc
    volumeStep  = 10, -- percent
    cursorTheme = "sweet-cursors",
    cursorSize  = 24,

    -- Keybind modifier combos, mirroring variables.conf exactly:
    --   mods-only ("SUPER+ALT") or "MODS, KEY" pairs. keybinds.lua parses these.
    kbMoveWinToWs       = "SUPER+ALT",
    kbMoveWinToWsGroup  = "CTRL+SUPER+ALT",
    kbGoToWs            = "SUPER",
    kbGoToWsGroup       = "CTRL+SUPER",
    kbNextWs            = "CTRL+SUPER, right",
    kbPrevWs            = "CTRL+SUPER, left",
    kbToggleSpecialWs   = "SUPER, S",

    kbWindowGroupCycleNext = "ALT, TAB",
    kbWindowGroupCyclePrev = "SHIFT+ALT, TAB",
    kbUngroup              = "SUPER, U",
    kbToggleGroup          = "SUPER, COMMA",

    kbMoveWindow               = "SUPER, Z",
    kbResizeWindow             = "SUPER, X",
    kbWindowPip                = "SUPER+ALT, BACKSLASH",
    kbPinWindow                = "SUPER, P",
    kbWindowFullscreen         = "SUPER, F",
    kbWindowBorderedFullscreen = "SUPER+ALT, F",
    kbToggleWindowFloating     = "SUPER+ALT, SPACE",
    kbCloseWindow              = "SUPER, Q",

    kbSystemMonitor = "CTRL+SHIFT, ESCAPE",
    kbMusic         = "SUPER, M",
    kbCommunication = "SUPER, D",
    kbTodo          = "SUPER, R",

    kbTerminal     = "SUPER, T",
    kbBrowser      = "SUPER, W",
    kbEditor       = "SUPER, C",
    kbFileExplorer = "SUPER, E",

    kbSession     = "CTRL+ALT, DELETE",
    kbClearNotifs = "CTRL+ALT, C",
    kbShowPanels  = "SUPER, K",
    kbLock        = "SUPER, L",
    kbRestoreLock = "SUPER+ALT, L",

    wsaction = HOME .. "/.config/hypr/scripts/wsaction.fish",
}

-- User variables: ~/.config/caelestia/hypr-vars.conf (hyprlang $name = value)
local uf = io.open(HOME .. "/.config/caelestia/hypr-vars.conf", "r")
if uf then
    for line in uf:lines() do
        local k, v = line:match("^%$([%w_]+)%s*=%s*(.-)%s*$")
        if k and v ~= "" and vars[k] ~= nil then
            local num = tonumber(v)
            vars[k] = num or v
        end
    end
    uf:close()
end

return vars