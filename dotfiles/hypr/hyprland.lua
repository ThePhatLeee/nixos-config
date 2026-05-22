-- ── Hyprland config entry point ───────────────────────────────────────
-- Edit any conf/*.lua file and run `hyprctl reload` — no rebuild needed.

require("conf.general")
require("conf.monitors")
require("conf.appearance")
require("conf.animations")
require("conf.input")
require("conf.keybinds")
require("conf.workspaces")
require("conf.windowrules")
require("conf.autostart")

-- This loads Noctalia-generated Hyprland colors.
dofile("/home/phatle/.config/hypr/noctalia/noctalia-colors.lua")
