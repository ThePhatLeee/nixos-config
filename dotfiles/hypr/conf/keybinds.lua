-- ── Keybinds ──────────────────────────────────────────────────────────
local mod = "SUPER"
local ipc = "noctalia-shell ipc call"

-- ── Apps (COSMIC-style: SUPER + letter = app) ─────────────────────────
hl.bind(mod .. " + T",         hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + B",         hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + E",         hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + G",         hl.dsp.exec_cmd("hyprpicker -a"))

-- ── Window management ─────────────────────────────────────────────────
hl.bind(mod .. " + Q",         hl.dsp.window.close())
hl.bind(mod .. " + F",         hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",         hl.dsp.window.pseudo())

-- ── Focus ──────────────────────────────────────────────────────────────
hl.bind(mod .. " + H",     hl.dsp.focus({ direction = "left"  }))
hl.bind(mod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K",     hl.dsp.focus({ direction = "up"    }))
hl.bind(mod .. " + J",     hl.dsp.focus({ direction = "down"  }))
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down"  }))

-- ── Window movement ────────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left"  }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up"    }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down"  }))

-- ── Workspaces ────────────────────────────────────────────────────────
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ── Scratchpad ────────────────────────────────────────────────────────
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- ── Resize (repeatable) ───────────────────────────────────────────────
hl.bind(mod .. " + ALT + H", hl.dsp.window.resize({ x = -20, y = 0   }), { repeating = true })
hl.bind(mod .. " + ALT + L", hl.dsp.window.resize({ x =  20, y = 0   }), { repeating = true })
hl.bind(mod .. " + ALT + K", hl.dsp.window.resize({ x = 0,   y = -20 }), { repeating = true })
hl.bind(mod .. " + ALT + J", hl.dsp.window.resize({ x = 0,   y =  20 }), { repeating = true })

-- ── Mouse window operations ───────────────────────────────────────────
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Screenshots ───────────────────────────────────────────────────────
hl.bind("Print",           hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SHIFT + Print",   hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))

-- ── Noctalia Shell ────────────────────────────────────────────────────
hl.bind(mod .. " + SPACE",    hl.dsp.exec_cmd(ipc .. " launcher toggle"))
hl.bind(mod .. " + TAB",      hl.dsp.exec_cmd(ipc .. " launcher windows"))
hl.bind(mod .. " + grave",    hl.dsp.exec_cmd(ipc .. " launcher clipboard"))
hl.bind(mod .. " + PERIOD",   hl.dsp.exec_cmd(ipc .. " launcher emoji"))
hl.bind(mod .. " + N",        hl.dsp.exec_cmd(ipc .. " controlCenter toggle"))
hl.bind(mod .. " + COMMA",    hl.dsp.exec_cmd(ipc .. " settings toggle"))
hl.bind(mod .. " + CTRL + L", hl.dsp.exec_cmd(ipc .. " lockScreen lock"))
hl.bind(mod .. " + ESCAPE",   hl.dsp.exec_cmd(ipc .. " sessionMenu toggle"))
hl.bind(mod .. " + CTRL + M", hl.dsp.exec_cmd(ipc .. " systemMonitor toggle"))

-- ── Volume (Noctalia IPC — locked so works on lock screen) ────────────
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume increase"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume decrease"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(ipc .. " volume muteOutput"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(ipc .. " volume muteInput"),  { locked = true })

-- ── Brightness (Noctalia IPC) ─────────────────────────────────────────
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(ipc .. " brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness decrease"), { locked = true, repeating = true })

-- ── Media (Noctalia IPC) ──────────────────────────────────────────────
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(ipc .. " media next"),      { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. " media playPause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(ipc .. " media playPause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(ipc .. " media previous"),  { locked = true })
