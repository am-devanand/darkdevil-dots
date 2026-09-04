-- keybinds.lua — replaces hyprland/keybinds.conf (submap = global)
local vars = require("modules.vars")

local function combo(str, key)
    local mods, k = str:match("^([^,]+),%s*(.+)$")
    if not mods then
        mods, k = str, key
    end
    local parts = {}
    for m in mods:gmatch("[^+]+") do
        parts[#parts + 1] = m:upper()
    end
    if k then
        parts[#parts + 1] = k
    end
    return table.concat(parts, " + ")
end

local function resizeDelta(dx, dy)
    return function()
        local w = hl.get_active_window()
        if not w then
            return
        end
        hl.dsp.window.resize({ x = dx * w.size.x, y = dy * w.size.y, relative = true })
    end
end

local function resizeExact(px, py)
    return function()
        local m = hl.get_active_monitor()
        if not m then
            return
        end
        hl.dsp.window.resize({ x = px * m.size.width, y = py * m.size.height, relative = false })
    end
end

hl.define_submap("global", function()
    -- Shell keybinds: launcher (bindin)
    local launcherOpts = { non_consuming = true, ignore_mods = true }
    hl.bind("SUPER + SUPER_L", hl.dsp.global("caelestia:launcher"), launcherOpts)
    hl.bind("SUPER + TAB", hl.dsp.global("caelestia:launcher"), launcherOpts)
    -- legacy "Super, catchall" + bindin: ignore_mods bypasses modmask, so plain catchall is exact
    hl.bind("catchall", hl.dsp.global("caelestia:launcherInterrupt"), launcherOpts)
    for i = 272, 277 do
        hl.bind("SUPER + mouse:" .. i, hl.dsp.global("caelestia:launcherInterrupt"), launcherOpts)
    end
    hl.bind("SUPER + mouse_up", hl.dsp.global("caelestia:launcherInterrupt"), launcherOpts)
    hl.bind("SUPER + mouse_down", hl.dsp.global("caelestia:launcherInterrupt"), launcherOpts)

    -- Launcher (direct IPC toggle: bypasses the hold-to-release shortcut, which is
    -- cancelled by the catchall launcherInterrupt on every keypress)
    hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs -c caelestia ipc call drawers toggle launcher"))

    -- Apps

hl.bind("SUPER + B", hl.dsp.exec_cmd("brave"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("codium"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("tradingview"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("kwrite"))

hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("brave-hnpfjngllnobngcgfapefoaidbinmjnm-Default"))
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("foot"))

    -- Copilot key → WhatsApp Web (covers all firmware variants of the physical Copilot button)
    hl.bind("F23", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-whatsapp.sh"))
    hl.bind("SUPER + F23", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-whatsapp.sh"))
    hl.bind("SUPER + SHIFT + F23", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-whatsapp.sh"))
    hl.bind("XF86LaunchA", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-whatsapp.sh"))
    hl.bind("XF86Tools", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-whatsapp.sh"))
    hl.bind("XF86LaunchB", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-whatsapp.sh"))

    -- Misc
    hl.bind(combo(vars.kbSession), hl.dsp.global("caelestia:session"))
    hl.bind(combo(vars.kbClearNotifs), hl.dsp.global("caelestia:clearNotifs"), { locked = true })
    hl.bind(combo(vars.kbShowPanels), hl.dsp.global("caelestia:showall"))
    hl.bind(combo(vars.kbLock), hl.dsp.global("caelestia:lock"))

    -- Restore lock
    hl.bind(combo(vars.kbRestoreLock), hl.dsp.exec_cmd("caelestia shell -d"), { locked = true })
    hl.bind(combo(vars.kbRestoreLock), hl.dsp.global("caelestia:lock"), { locked = true })

    -- Brightness
    hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true })

    -- Media
    hl.bind("CTRL + SUPER + SPACE", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("CTRL + SUPER + EQUAL", hl.dsp.global("caelestia:mediaNext"), { locked = true })
    hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
    hl.bind("CTRL + SUPER + MINUS", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
    hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true })

    -- Kill/restart (bindr)
    hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"), { release = true })
    hl.bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"), { release = true })

    

    -- Go to workspace -1/+1
    hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" }))
    hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" }))
    hl.bind(combo(vars.kbPrevWs), hl.dsp.focus({ workspace = "-1" }), { repeating = true })
    hl.bind(combo(vars.kbNextWs), hl.dsp.focus({ workspace = "+1" }), { repeating = true })
    hl.bind("SUPER + PAGE_UP", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
    hl.bind("SUPER + PAGE_DOWN", hl.dsp.focus({ workspace = "+1" }), { repeating = true })

    -- Go to workspace group -1/+1
    hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "-10" }))
    hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "+10" }))

    -- Toggle special workspace
    hl.bind(combo(vars.kbToggleSpecialWs), hl.dsp.exec_cmd("caelestia toggle specialws"))

    -- Go to workspace (digits)
    for i = 1, 9 do
        hl.bind(combo(vars.kbGoToWs, tostring(i)), hl.dsp.focus({ workspace = tostring(i) }))
    end
    hl.bind(combo(vars.kbGoToWs, "0"), hl.dsp.focus({ workspace = "10" }))

    -- Move window to workspace (digits)
    for i = 1, 9 do
        hl.bind(combo(vars.kbMoveWinToWs, tostring(i)), hl.dsp.exec_cmd(vars.wsaction .. " movetoworkspace " .. i))
    end
    hl.bind(combo(vars.kbMoveWinToWs, "0"), hl.dsp.exec_cmd(vars.wsaction .. " movetoworkspace 10"))

    -- Move window to workspace group
    for i = 1, 9 do
        hl.bind(combo(vars.kbMoveWinToWsGroup, tostring(i)), hl.dsp.exec_cmd(vars.wsaction .. " -g movetoworkspace " .. i))
    end
    hl.bind(combo(vars.kbMoveWinToWsGroup, "0"), hl.dsp.exec_cmd(vars.wsaction .. " -g movetoworkspace 10"))

    -- Move window to workspace -1/+1
    hl.bind("SUPER + ALT + PAGE_UP", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
    hl.bind("SUPER + ALT + PAGE_DOWN", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
    hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
    hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))
    hl.bind("CTRL + SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
    hl.bind("CTRL + SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })

    -- Move window to/from special workspace
    hl.bind("CTRL + SUPER + SHIFT + up", hl.dsp.window.move({ workspace = "special:special" }))
    hl.bind("CTRL + SUPER + SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }))
    hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }))

    -- Window groups
    hl.bind(combo(vars.kbWindowGroupCycleNext), hl.dsp.window.cycle_next(), { repeating = true })
    hl.bind(combo(vars.kbWindowGroupCyclePrev), hl.dsp.window.cycle_next({ next = false }), { repeating = true })
    hl.bind("CTRL + ALT + TAB", hl.dsp.group.next(), { repeating = true })
    hl.bind("CTRL + SHIFT + ALT + TAB", hl.dsp.group.prev(), { repeating = true })
    hl.bind(combo(vars.kbToggleGroup), hl.dsp.group.toggle())
    hl.bind(combo(vars.kbUngroup), hl.dsp.window.move({ out_of_group = true }))
    hl.bind("SUPER + SHIFT + COMMA", hl.dsp.group.lock_active({ action = "toggle" }))

    -- Window actions
    hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
    hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
    hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
    hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
    hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
    hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
    hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
    hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

    -- Resize (percentage of window size)
    hl.bind("SUPER + MINUS", resizeDelta(-0.10, 0), { repeating = true })
    hl.bind("SUPER + EQUAL", resizeDelta(0.10, 0), { repeating = true })
    hl.bind("SUPER + SHIFT + MINUS", resizeDelta(0, -0.10), { repeating = true })
    hl.bind("SUPER + SHIFT + EQUAL", resizeDelta(0, 0.10), { repeating = true })
    hl.bind("SUPER + ALT + left", resizeDelta(-0.10, 0), { repeating = true })
    hl.bind("SUPER + ALT + right", resizeDelta(0.10, 0), { repeating = true })
    hl.bind("SUPER + ALT + up", resizeDelta(0, -0.10), { repeating = true })
    hl.bind("SUPER + ALT + down", resizeDelta(0, 0.10), { repeating = true })

    -- Mouse drag/resize (bindm)
    hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(combo(vars.kbMoveWindow), hl.dsp.window.drag(), { mouse = true })
    hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
    hl.bind(combo(vars.kbResizeWindow), hl.dsp.window.resize(), { mouse = true })

    -- Window actions
    hl.bind("CTRL + SUPER + BACKSLASH", hl.dsp.window.center())
    hl.bind("CTRL + SUPER + ALT + BACKSLASH", resizeExact(0.55, 0.70))
    hl.bind("CTRL + SUPER + ALT + BACKSLASH", hl.dsp.window.center())
    hl.bind(combo(vars.kbWindowPip), hl.dsp.exec_cmd("caelestia resizer pip"))
    hl.bind(combo(vars.kbPinWindow), hl.dsp.window.pin({ action = "toggle" }))
    hl.bind(combo(vars.kbWindowFullscreen), hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
    hl.bind(combo(vars.kbWindowBorderedFullscreen), hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
    hl.bind(combo(vars.kbToggleWindowFloating), hl.dsp.window.float({ action = "toggle" }))
    hl.bind(combo(vars.kbCloseWindow), hl.dsp.window.kill())

    -- Special workspace toggles
    hl.bind(combo(vars.kbSystemMonitor), hl.dsp.exec_cmd("caelestia toggle sysmon"))
    hl.bind(combo(vars.kbMusic), hl.dsp.exec_cmd("caelestia toggle music"))
    hl.bind(combo(vars.kbCommunication), hl.dsp.exec_cmd("caelestia toggle communication"))
    hl.bind(combo(vars.kbTodo), hl.dsp.exec_cmd("caelestia toggle todo"))

    -- Apps
    hl.bind(combo(vars.kbTerminal), hl.dsp.exec_cmd("app2unit -- " .. vars.terminal))
    hl.bind(combo(vars.kbBrowser), hl.dsp.exec_cmd("app2unit -- " .. vars.browser))
    hl.bind(combo(vars.kbEditor), hl.dsp.exec_cmd("app2unit -- " .. vars.editor))
    hl.bind("SUPER + G", hl.dsp.exec_cmd("app2unit -- github-desktop"))
    hl.bind(combo(vars.kbFileExplorer), hl.dsp.exec_cmd("app2unit -- " .. vars.fileExplorer))
    hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd("app2unit -- nemo"))
    hl.bind("CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("app2unit -- qps"))
    hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("app2unit -- pavucontrol"))

    -- Utilities
    hl.bind("PRINT", hl.dsp.exec_cmd("caelestia screenshot"), { locked = true })
    hl.bind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshotFreeze"))
    hl.bind("SUPER + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshot"))
    hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("caelestia record -s"))
    hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("caelestia record"))
    hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd("caelestia record -r"))
    hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

    -- Volume
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind("XF86AudioRaiseVolume",
        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"),
        { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume",
        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"),
        { locked = true, repeating = true })

    -- Sleep
    hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), { locked = true })

    -- Clipboard and emoji picker
    hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
    hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
    hl.bind("SUPER + PERIOD", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))
    hl.bind("CTRL + SHIFT + ALT + V",
        hl.dsp.exec_cmd("sleep 0.5s && ydotool type -d 1 \"$(cliphist list | head -1 | cliphist decode)\""),
        { locked = true })

    -- Testing
    hl.bind("SUPER + ALT + F12",
        hl.dsp.exec_cmd("notify-send -u low -i dialog-information-symbolic 'Test notification' \"Here's a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!\" -a 'Shell' -A \"Test1=I got it!\" -A \"Test2=Another action\""),
        { locked = true })
end)