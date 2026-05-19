-- ── Window Rules ──────────────────────────────────────────────────────

-- Suppress maximize requests from all apps
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag ghost windows
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Common dialogs
hl.window_rule({ name = "float-portal",    match = { class = "xdg-desktop-portal.*" }, float = true })
hl.window_rule({ name = "float-fileroller",match = { class = "file-roller"           }, float = true })
hl.window_rule({ name = "float-openfile",  match = { title = "Open File.*"           }, float = true })
hl.window_rule({ name = "float-saveas",    match = { title = "Save As.*"             }, float = true })

-- Picture-in-picture
hl.window_rule({ name = "pip-float",  match = { title = "Picture-in-Picture" }, float = true })
hl.window_rule({ name = "pip-ratio",  match = { title = "Picture-in-Picture" }, keep_aspect_ratio = true })
hl.window_rule({ name = "pip-pin",    match = { title = "Picture-in-Picture" }, pin = true })

-- Hyprlock
hl.window_rule({ name = "hyprlock-fs",  match = { class = "hyprlock" }, fullscreen = true })

-- Blueman
hl.window_rule({ name = "blueman-float",  match = { class = "blueman-manager" }, float  = true })
hl.window_rule({ name = "blueman-center", match = { class = "blueman-manager" }, center = true })

-- Nautilus property dialogs
hl.window_rule({ name = "nautilus-props", match = { class = "org.gnome.Nautilus", title = "Properties" }, float = true })
