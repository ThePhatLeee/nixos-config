-- ── Autostart ─────────────────────────────────────────────────────────
-- Noctalia v4 owns: idle (ext-idle-notify-v1), lock screen, polkit
-- (via the polkit-agent plugin), clipboard watchers (spawns
-- clipboardWatchTextCommand/ImageCommand on shell start with watchdog),
-- brightness, wallpaper, nightLight. Don't duplicate those here.

hl.on("hyprland.start", function()
    -- Desktop shell — also brings up idle, polkit, clipboard watchers
    hl.exec_cmd("noctalia-shell")

    -- Staggered app autostart — workspace rules assign silently, focus stays on WP2
    hl.exec_cmd("code --new-window")
    hl.exec_cmd("sleep 2 && firefox")
    hl.exec_cmd("sleep 4 && thunderbird")
    hl.exec_cmd("sleep 6 && signal-desktop")
    hl.exec_cmd("sleep 3 && hyprctl dispatch workspace 2")
end)
