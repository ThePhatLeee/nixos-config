-- ── Autostart ─────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hyprsunset -t 4500")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Tray applets
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")

    -- Desktop shell
    hl.exec_cmd("noctalia-shell")
end)
