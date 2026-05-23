-- Active border: Compline bright.black (#515761) — subtle steel, shows focus without noise.
-- Inactive border: #22262b — hairline, near-invisible.
-- This always runs after noctalia-colors.lua so Noctalia theme changes can't revert it.
local active   = "rgb(515761)"
local inactive = "rgb(22262b)"

hl.config({
    general = {
        col = {
            active_border   = active,
            inactive_border = inactive,
        },
    },
    group = {
        col = {
            border_active          = active,
            border_inactive        = inactive,
            border_locked_active   = active,
            border_locked_inactive = inactive,
        },
        groupbar = {
            col = {
                active          = active,
                inactive        = inactive,
                locked_active   = active,
                locked_inactive = inactive,
            },
        },
    },
})
