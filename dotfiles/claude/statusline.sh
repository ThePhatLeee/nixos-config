#!/usr/bin/env bash
# Claude Code statusline — Tokyo Night starship palette
# Segments: #a3aed2 → #769ff0 → #394260 → #212736 → #1d2230

R='\e[0m'

B1='\e[48;2;163;174;210m'      # #a3aed2
B2='\e[48;2;118;159;240m'      # #769ff0
B3='\e[48;2;57;66;96m'         # #394260
BL='\e[48;2;33;39;54m'         # #212736
B4='\e[48;2;29;34;48m'         # #1d2230

F_DARK='\e[38;2;9;12;12m'
F_LIGHT='\e[38;2;227;229;229m'
F_DIM='\e[38;2;163;174;210m'
F_PRI='\e[38;2;118;159;240m'
F_MID='\e[38;2;57;66;96m'
F_LNG='\e[38;2;33;39;54m'
F_SRF='\e[38;2;29;34;48m'
F_MUTED='\e[38;2;160;169;203m'
F_GRN='\e[38;2;155;254;206m'
F_YLW='\e[38;2;255;245;155m'
F_RED='\e[38;2;253;70;99m'

A=$(printf '\xee\x82\xb4')     # U+E0B4 rounded separator

# ── Icons ──────────────────────────────────────────────────────────────
I_BRANCH=$(printf '\xee\x82\xa0')  # U+E0A0  pl-branch
I_NIX=$(printf '\xef\x8c\x93')     # U+F313  linux-nixos
I_RUST=$(printf '\xee\x9e\xa8')    # U+E7A8  dev-rust
I_GO=$(printf '\xee\x98\xa7')      # U+E627  seti-go
I_NODE=$(printf '\xee\x9c\x98')    # U+E718  dev-nodejs_small
I_BUN=$(printf '\xee\x9d\xaf')     # U+E76F  dev-bun
I_TS=$(printf '\xee\x98\xa8')      # U+E628  seti-typescript
I_PHP=$(printf '\xee\x98\x88')     # U+E608  seti-php
I_LARAVEL=$(printf '\xee\x9c\xbf') # U+E73F  dev-laravel
I_PY=$(printf '\xee\x9c\xbc')      # U+E73C  dev-python
I_REACT=$(printf '\xee\x9e\xba')   # U+E7BA  dev-react
I_LUA=$(printf '\xee\x98\xa0')     # U+E620  seti-lua
I_C=$(printf '\xee\x98\x9e')       # U+E61E  custom-c

input=$(cat)
model=$(echo "$input"    | jq -r '.model.display_name // ""')
cwd=$(echo "$input"      | jq -r '.workspace.current_dir // .cwd // ""')
used_pct=$(echo "$input"      | jq -r '.context_window.used_percentage // empty')
vim_mode=$(echo "$input"      | jq -r '.vim.mode // empty')
five_h=$(echo "$input"        | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_reset=$(echo "$input"  | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d=$(echo "$input"       | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

short_cwd=$(echo "$cwd" | awk -F/ '{
  n=NF
  if (n==0) { print "/"; next }
  if ($1=="" && n<=3) { print $0; next }
  if ($1=="" && n>3) { print "…/" $(n-1) "/" $n; next }
  if (n<=2) { print $0; next }
  print "…/" $(n-1) "/" $n
}')

# ── Git ────────────────────────────────────────────────────────────────
branch=""
git_flags=""
if [ -n "$cwd" ]; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    porcelain=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null)
    [ -n "$porcelain" ] && git_flags="*"
    ahead=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-list --count @{u}..HEAD 2>/dev/null)
    behind=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-list --count HEAD..@{u} 2>/dev/null)
    [ "${ahead:-0}" -gt 0 ] 2>/dev/null && git_flags="${git_flags}↑"
    [ "${behind:-0}" -gt 0 ] 2>/dev/null && git_flags="${git_flags}↓"
  fi
fi

# ── Stack detection ────────────────────────────────────────────────────
stack=""
if [ -n "$cwd" ]; then
  { [ -f "$cwd/flake.nix" ] || [ -f "$cwd/default.nix" ]; } && stack+="$I_NIX "
  [ -f "$cwd/Cargo.toml" ]   && stack+="$I_RUST "
  [ -f "$cwd/go.mod" ]       && stack+="$I_GO "
  { [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/setup.py" ]; } && stack+="$I_PY "
  if [ -f "$cwd/package.json" ]; then
    [ -f "$cwd/bun.lockb" ] && stack+="$I_BUN " || stack+="$I_NODE "
    grep -q '"react"' "$cwd/package.json" 2>/dev/null && stack+="$I_REACT "
    [ -f "$cwd/tsconfig.json" ] && stack+="$I_TS "
  fi
  [ -f "$cwd/artisan" ]        && stack+="$I_LARAVEL " || { [ -f "$cwd/composer.json" ] && stack+="$I_PHP "; }
  [ -f "$cwd/CMakeLists.txt" ] && stack+="$I_C "
  { [ -f "$cwd/conf.lua" ] || [ -f "$cwd/init.lua" ]; } && stack+="$I_LUA "
fi

# ── Vim badge ──────────────────────────────────────────────────────────
badge=""
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    INSERT)  badge=" ${F_GRN}I${F_DARK}" ;;
    NORMAL)  badge=" ${F_PRI}N${F_DARK}" ;;
    VISUAL*) badge=" ${F_YLW}V${F_DARK}" ;;
    *)       badge=" ${F_DIM}${vim_mode}${F_DARK}" ;;
  esac
fi

model_label=$(echo "$model" | sed 's/^[Cc]laude //')

# ── Reset timer helper ─────────────────────────────────────────────────
fmt_reset() {
  local ts=$1
  [ -z "$ts" ] && return
  local diff=$(( ts - $(date +%s) ))
  [ "$diff" -le 0 ] && return
  local d=$(( diff / 86400 ))
  local h=$(( (diff % 86400) / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  if [ "$d" -gt 0 ]; then
    printf '%dd %dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then
    printf '%dh %dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

# ── Ctx / rate info ────────────────────────────────────────────────────
ctx_info=""
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if   [ "$used_int" -ge 85 ]; then cc="$F_RED"
  elif [ "$used_int" -ge 60 ]; then cc="$F_YLW"
  else                               cc="$F_PRI"
  fi
  ctx_info="${F_MUTED}context ${cc}${used_int}%"
fi

if [ -n "$five_h" ]; then
  five_int=$(printf '%.0f' "$five_h")
  if [ "$five_int" -ge 10 ]; then
    if   [ "$five_int" -ge 80 ]; then fc="$F_RED"
    elif [ "$five_int" -ge 50 ]; then fc="$F_YLW"
    else                               fc="$F_MUTED"
    fi
    reset_str=$(fmt_reset "$five_h_reset")
    ctx_info="${ctx_info:+${ctx_info} ${F_SRF}·${F_MUTED} }${fc}session ${five_int}%${reset_str:+ ${F_MUTED}(${reset_str})}"
  fi
fi

if [ -n "$seven_d" ]; then
  seven_int=$(printf '%.0f' "$seven_d")
  if [ "$seven_int" -ge 10 ]; then
    if   [ "$seven_int" -ge 80 ]; then wc="$F_RED"
    elif [ "$seven_int" -ge 50 ]; then wc="$F_YLW"
    else                               wc="$F_MUTED"
    fi
    reset_str=$(fmt_reset "$seven_d_reset")
    ctx_info="${ctx_info:+${ctx_info} ${F_SRF}·${F_MUTED} }${wc}weekly ${seven_int}%${reset_str:+ ${F_MUTED}(${reset_str})}"
  fi
fi

# ── Assemble ───────────────────────────────────────────────────────────
out=""

out+="${F_DIM}░▒▓${R}"

# Seg1 — #a3aed2: NixOS icon + vim badge
out+="${B1}${F_DARK} ${I_NIX}${badge} ${R}"

# → #769ff0
out+="${B2}${F_DIM}${A}"

# Seg2 — #769ff0: directory
out+="${F_LIGHT}  ${short_cwd} ${R}"

if [ -n "$branch" ]; then
  # → #394260
  out+="${B3}${F_PRI}${A}"
  # Seg3 — #394260: branch icon + name + flags
  out+="${F_PRI} ${I_BRANCH} ${branch}${git_flags:+ ${git_flags}} ${R}"
  # → #212736
  out+="${BL}${F_MID}${A}"
else
  out+="${BL}${F_PRI}${A}"
fi

# Seg4 — #212736: stack icons + model (mirrors starship language seg)
out+="${F_PRI} ${stack}${F_MUTED}${model_label:-claude} ${R}"

# → #1d2230
out+="${B4}${F_LNG}${A}"

# Seg5 — #1d2230: ctx + rate (mirrors starship time seg)
out+=" ${ctx_info:-${F_MUTED}…} ${R}"

out+="${F_SRF}${A}${R}"

printf "%b\n" "$out"
