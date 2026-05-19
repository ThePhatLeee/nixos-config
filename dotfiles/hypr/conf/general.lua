-- ── General / Layout ──────────────────────────────────────────────────

hl.config({
    general = {
        gaps_in          = 4,
        gaps_out         = 8,
        border_size      = 2,
        layout           = "dwindle",
        resize_on_border = true,
        allow_tearing    = false,
        col = {
            active_border   = { colors = { "rgba(cba6f7ff)", "rgba(89b4faff)" }, angle = 45 },
            inactive_border = "rgba(45475aaa)",
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
})
