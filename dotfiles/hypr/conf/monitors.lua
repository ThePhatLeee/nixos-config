-- ── Monitors ──────────────────────────────────────────────────────────

-- Auto-detect all monitors (preferred resolution, automatic position, auto scale)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Examples — uncomment and adjust for manual configuration:
-- hl.monitor({ output = "eDP-1",    mode = "2560x1600@165", position = "0x0",    scale = 1.6 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60",  position = "2560x0", scale = 1   })
