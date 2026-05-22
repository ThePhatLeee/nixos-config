# ── Prompt ────────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── Smart cd ──────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── History (atuin — CTRL+R) ──────────────────────────────────────────
eval "$(atuin init zsh --disable-up-arrow)"

# ── Yazi — exit into last directory ──────────────────────────────────
y() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ── nh os switch always uses --update ─────────────────────────────────
nh() {
  if [[ "${1:-}" == "os" && "${2:-}" == "switch" ]]; then
    command nh os switch --update "${@:3}"
  else
    command nh "$@"
  fi
}

# ── Aliases ───────────────────────────────────────────────────────────
alias cat="bat"
alias lg="lazygit"
alias du="dust"
alias df="duf"
alias tldr="tldr"
alias ..="cd .."
alias ...="cd ../.."

# ── Distrobox shortcuts ────────────────────────────────────────────────
alias fe="distrobox enter frontend"
alias be="distrobox enter backend"
alias fs="distrobox enter fullstack"
alias it="distrobox enter it"
alias dbl="distrobox list"
alias dbcr="distrobox create"
