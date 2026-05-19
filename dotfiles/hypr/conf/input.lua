-- ── Input ─────────────────────────────────────────────────────────────

hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE",  "24")
hl.env("XCURSOR_THEME",    "rose-pine-hyprcursor")
hl.env("XCURSOR_SIZE",     "24")

hl.config({
    cursor = {
        enable_hyprcursor    = true,
        sync_gsettings_theme = true,
        no_hardware_cursors  = false,
    },
})

hl.config({
    input = {
        kb_layout    = "fi",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        follow_mouse  = 1,
        sensitivity   = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            tap_to_click         = true,
            drag_lock            = true,
            scroll_factor        = 0.8,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
