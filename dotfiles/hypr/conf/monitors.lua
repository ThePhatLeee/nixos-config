-- ── Monitors ──────────────────────────────────────────────────────────
-- Static startup config. Kanshi overrides at runtime for docked/undocked profiles.

-- Internal 4K panel — explicit 1.2 scale; auto would pick 2.0
hl.monitor({ output = "eDP-1", mode = "3456x2160@60", position = "0x0", scale = 1.2 })

-- Catch-all for any connected external monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
