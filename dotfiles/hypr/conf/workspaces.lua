-- ── Workspaces ─────────────────────────────────────────────────────────

for i = 1, 7 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
