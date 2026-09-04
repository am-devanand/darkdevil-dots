--[[
    colors.lua — Material-3 palette loader.
    Replaces `source = $hypr/scheme/current.conf`.

    Reads scheme/current.conf (hyprlang format: `$name = hexvalue`) at load time
    so the Caelestia theme switcher keeps working — swap the scheme file and
    reload, and the new palette is picked up (same semantics as the old config).

    Returns { palette = {...}, rgba = fn(name, alpha_suffix), rgb = fn(name) }.
    `rgba("primary", "e6")` -> "rgba(897324e6)" exactly like the old
    `rgba($primarye6)` references in variables.conf.
--]]
local HOME      = os.getenv("HOME") or "/home/darkdevil"
local HYPR_DIR  = HOME .. "/.config/hypr"
local SCHEME    = HYPR_DIR .. "/scheme/current.conf"

local palette = {}

local function load_palette(path)
    local f = io.open(path, "r")
    if not f then
        return false
    end

    for line in f:lines() do
        local name, hex =
            line:match("^%$([%w_]+)%s*=%s*(%x+)%s*$")
        if name and hex then
            palette[name] = hex
        end
    end
    f:close()
    return next(palette) ~= nil
end

if not load_palette(SCHEME) then
    -- fallback, mirrors the old `exec = cp ... default.conf current.conf`
    load_palette(HYPR_DIR .. "/scheme/default.conf")
end

local function rgba(name, alpha)
    local hex = palette[name]
    return hex and ("rgba(" .. hex .. (alpha or "") .. ")") or "rgba(00000000)"
end

local function rgb(name)
    local hex = palette[name]
    return hex and ("rgb(" .. hex .. ")") or "rgb(000000)"
end

return { palette = palette, rgba = rgba, rgb = rgb }