-- ── Autostart ─────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("hypridle")

    -- Clipboard history backend (Noctalia launcher clipboard reads from cliphist)
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Desktop shell
    hl.exec_cmd("noctalia-shell")

    -- Staggered app autostart — workspace rules assign silently, focus stays on WP2
    hl.exec_cmd("code --new-window")
    hl.exec_cmd("sleep 2 && firefox")
    hl.exec_cmd("sleep 4 && thunderbird")
    hl.exec_cmd("sleep 6 && signal-desktop")
    hl.exec_cmd("sleep 3 && hyprctl dispatch workspace 2")
end)
