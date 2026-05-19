-- ── Appearance ────────────────────────────────────────────────────────

hl.config({
    decoration = {
        rounding       = 12,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled        = true,
            range          = 8,
            render_power   = 3,
            color          = "rgba(00000066)",
            color_inactive = "rgba(00000033)",
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
            xray              = false,
            vibrancy          = 0.17,
            vibrancy_darkness = 0.2,
        },
    },
})
