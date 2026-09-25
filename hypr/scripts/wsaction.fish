#!/usr/bin/env fish

if test "$argv[1]" = '-g'
    set group
    set -e $argv[1]
end

if test (count $argv) -ne 2
    echo 'Wrong number of arguments. Usage: ./wsaction.fish [-g] <dispatcher> <workspace>'
    exit 1
end

set -l active_ws (hyprctl activeworkspace -j | jq -r '.id')

# Hyprland 0.56 evaluates `hyprctl dispatch` args as Lua, so the classic
# `dispatch workspace N` form no longer parses. Dispatch via hl.dsp instead.
set -l ws
if set -q group
    # Move to group
    set ws (math "($argv[2] - 1) * 10 + $active_ws % 10")
else
    # Move to ws in group
    set ws (math "floor(($active_ws - 1) / 10) * 10 + $argv[2]")
end

switch $argv[1]
    case workspace
        hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = \"$ws\" }))"
    case movetoworkspace
        hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$ws\" }))"
    case '*'
        echo "Unknown dispatcher: $argv[1]"
        exit 1
end
