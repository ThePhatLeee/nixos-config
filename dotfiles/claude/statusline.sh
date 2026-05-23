#!/usr/bin/env bash
# Claude Code statusline — Compline/Noctalia palette
# Segments: #515761 → #3d424a → #282c34 → #22262b → #1a1d21

R='\e[0m'

B1='\e[48;2;81;87;97m'         # #515761
B2='\e[48;2;61;66;74m'         # #3d424a
B3='\e[48;2;40;44;52m'         # #282c34
BL='\e[48;2;34;38;43m'         # #22262b
B4='\e[48;2;26;29;33m'         # #1a1d21

F_DARK='\e[38;2;26;29;33m'     # #1a1d21  dark fg on Seg1
F_LIGHT='\e[38;2;240;239;235m' # #f0efeb  bright fg on dir
F_DIM='\e[38;2;81;87;97m'      # #515761 = B1  (░▒▓ + Seg1→2 arrow)
F_PRI='\e[38;2;61;66;74m'      # #3d424a = B2  (Seg2→3 arrow only)
F_ACC='\e[38;2;180;188;196m'   # #b4bcc4  accent text (git, stack, vim normal)
F_MID='\e[38;2;40;44;52m'      # #282c34 = B3  (Seg3→4 arrow)
F_LNG='\e[38;2;34;38;43m'      # #22262b = BL  (Seg4→5 arrow)
F_SRF='\e[38;2;26;29;33m'      # #1a1d21 = B4  (trailing arrow)
F_MUTED='\e[38;2;81;87;97m'    # #515761  muted text
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
I_BOX=$(printf '\xf3\xb0\x83\x95') # U+F00D5 mdi-package
I_BAT=$(printf '\xf3\xb0\x84\x9c') # U+F011C mdi-battery

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
  fi
  [ -f "$cwd/artisan" ]        && stack+="$I_LARAVEL " || { [ -f "$cwd/composer.json" ] && stack+="$I_PHP "; }
  [ -f "$cwd/CMakeLists.txt" ] && stack+="$I_C "
  { [ -f "$cwd/conf.lua" ] || [ -f "$cwd/init.lua" ]; } && stack+="$I_LUA "
fi

# ── Vim badge ──────────────────────────────────────────────────────────
badge=""
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    INSERT)  badge="" ;;
    NORMAL)  badge=" ${F_ACC}N${F_DARK}" ;;
    VISUAL*) badge=" ${F_YLW}V${F_DARK}" ;;
    *)       badge=" ${F_DIM}${vim_mode}${F_DARK}" ;;
  esac
fi

model_label=$(echo "$model" | sed 's/^[Cc]laude //')

# ── Distrobox container detection ──────────────────────────────────────
# distrobox-enter sets CONTAINER_ID; toolbx sets HOSTNAME=toolbox + a marker.
container=""
[ -n "${CONTAINER_ID:-}" ] && container="$CONTAINER_ID"
[ -z "$container" ] && [ -f /run/.containerenv ] && container=$(grep -oP 'name="\K[^"]+' /run/.containerenv 2>/dev/null || true)

# ── Battery (silent on desktop / no BAT0) ──────────────────────────────
bat_pct=""
bat_status=""
if [ -r /sys/class/power_supply/BAT0/capacity ]; then
  bat_pct=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
  bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
fi

# ── Flake-dirty indicator (only when cwd is inside ~/nixos-config) ─────
flake_dirty=""
if [ -n "$cwd" ] && [ -f "$cwd/flake.lock" ]; then
  GIT_OPTIONAL_LOCKS=0 git -C "$cwd" diff --quiet flake.lock flake.nix 2>/dev/null || flake_dirty="1"
fi

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
  else                               cc="$F_ACC"
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

# Seg1 — #a3aed2: NixOS icon + optional distrobox + vim badge
seg1_extra=""
[ -n "$container" ] && seg1_extra=" ${I_BOX} ${container}"
out+="${B1}${F_DARK} ${I_NIX}${seg1_extra}${badge} ${R}"

# → #769ff0
out+="${B2}${F_DIM}${A}"

# Seg2 — #769ff0: directory
out+="${F_LIGHT}  ${short_cwd} ${R}"

if [ -n "$branch" ]; then
  # → #394260
  out+="${B3}${F_PRI}${A}"
  # Seg3 — #282c34: branch icon + name + flags
  out+="${F_ACC} ${I_BRANCH} ${branch}${git_flags:+ ${git_flags}} ${R}"
  # → #212736
  out+="${BL}${F_MID}${A}"
else
  out+="${BL}${F_PRI}${A}"
fi

# Seg4 — #22262b: stack icons + model (mirrors starship language seg)
out+="${F_ACC} ${stack}${F_MUTED}${model_label:-claude} ${R}"

# → #1d2230
out+="${B4}${F_LNG}${A}"

# ── Seg5 prefix: battery + flake-dirty indicators ─────────────────────
extras=""
if [ -n "$bat_pct" ]; then
  if   [ "$bat_pct" -lt 20 ]; then bc="$F_RED"
  elif [ "$bat_pct" -lt 40 ]; then bc="$F_YLW"
  else                              bc="$F_MUTED"
  fi
  charging=""
  [ "$bat_status" = "Charging" ] && charging="+"
  extras="${bc}${I_BAT} ${bat_pct}%${charging}"
fi
if [ -n "$flake_dirty" ]; then
  extras="${extras:+${extras} ${F_SRF}·${F_MUTED} }${F_YLW}flake*"
fi

# Seg5 — #1d2230: ctx + rate + battery + flake (mirrors starship time seg)
out+=" ${extras:+${extras} ${F_SRF}·${F_MUTED} }${ctx_info:-${F_MUTED}…} ${R}"

out+="${F_SRF}${A}${R}"

printf "%b\n" "$out"
