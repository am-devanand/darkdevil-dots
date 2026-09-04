-- animations.lua — curves + animations (replaces hyprland/animations.conf)

hl.config({ animations = { enabled = true } })

-- Curves (hyprlang `bezier = name, x1, y1, x2, y2` -> hl.curve)
hl.curve("specialWorkSwitch", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("emphasizedAccel",   { type = "bezier", points = { {0.3, 0},   {0.8, 0.15} } })
hl.curve("emphasizedDecel",   { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("standard",          { type = "bezier", points = { {0.2, 0},   {0, 1} } })

-- Animations (hyprlang `animation = leaf, 1, speed, bezier[, style]`)
hl.animation({ leaf = "layersIn",        enabled = true, speed = 5, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut",       enabled = true, speed = 4, bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "fadeLayers",      enabled = true, speed = 5, bezier = "standard" })

hl.animation({ leaf = "windowsIn",       enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut",      enabled = true, speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove",     enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "workspaces",      enabled = true, speed = 5, bezier = "standard" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert 15%" })

hl.animation({ leaf = "fade",   enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "standard" })