---
name: distrobox
description: Use for distrobox/podman container work on this NixOS host — entering, creating, troubleshooting, choosing container vs VM, VSCode dev-container attach, host↔container file boundaries. Auto-triggers on: distrobox, podman container, container dev, frontend container, backend container, fullstack container, ubuntu container.
---

# Distrobox on NixOS

The host runs minimal — no language runtimes, no SDKs. All dev work happens inside Ubuntu 24.04 distrobox containers. See `DISTROBOX_SETUP.md` for full stack.

## Container topology

| name      | --nvidia | stack                                                           | enter alias |
|-----------|----------|-----------------------------------------------------------------|-------------|
| frontend  | yes      | Node + pnpm + bun + Three.js/WebGL                              | `fe`        |
| backend   | no       | PHP/Laravel + Python + Java + .NET + Go + Rust + C++ + MySQL/PG | `be`        |
| fullstack | yes      | frontend + backend combined                                     | `fs`        |
| it        | no       | Ansible + AD/LDAP + PowerShell + network tools                  | `it`        |

`dbl` = `distrobox list`, `dbcr` = `distrobox create`.

## Container vs VM — decision rule

| Use container | Use Kali/Windows VM |
|---|---|
| Language runtime, dev tools | Anything offensive (Metasploit, Burp, exploit dev) |
| Local dev DB (Postgres, Mongo) | Kernel work, custom kernel modules |
| HTTP services, build tools | Windows-only software, RDP, AD lab |
| Reproducible build env | USB passthrough, hardware testing |

Offensive security tooling NEVER on host or in distrobox — Kali VM only. The `it` container is for infra automation (Ansible, AD client tools, PowerShell), not for pentesting.

## File boundaries (these are easy to forget)

- Host `~/...` ↔ container `~/...` — same path, same UID, instant sync
- Host `/etc`, `/var`, `/run` ↔ container — separate copies; don't expect host services to appear inside
- Container `apt install` → container only; doesn't pollute host
- Container `service postgresql start` → not a systemd unit; dies when container exits (the `~/.bashrc` re-starts it on next entry — see DISTROBOX_SETUP.md)
- Container processes can be seen on host with `ps aux | grep <container-pid>`; they share the host kernel

## Entering / running

```bash
fe                                  # interactive shell in frontend
distrobox enter frontend -- pnpm i  # one-off command, no shell
distrobox enter -nw frontend        # no-workdir: open in $HOME not $PWD
```

## VSCode attach

1. Install **Dev Containers** extension on host VSCode (NixOS `vscode.fhs`)
2. Container must be running: `fe` once first
3. `Ctrl+Shift+P` → "Dev Containers: Attach to Running Container" → pick
4. VSCode opens a new window connected to the container; install extensions there (separate from host)

For repeat projects, add `.devcontainer/devcontainer.json`:
```json
{
  "name": "backend",
  "extensions": ["bmewburn.vscode-intelephense-client", "ms-python.python"]
}
```

## Creating a one-off

```bash
distrobox create -n scratch -i ubuntu:24.04 -Y
distrobox enter scratch
# work...
exit
distrobox rm scratch -f
```

`-Y` = yes-to-all prompts. Image is pulled from docker.io (registry order set in `modules/nixos/system/containers.nix`).

## NVIDIA / CUDA verification (frontend, fullstack)

```bash
fe
nvidia-smi              # must show RTX 3050 Ti
node -e 'console.log(process.env.LD_LIBRARY_PATH)' | grep -o nvidia  # bind mount
```

If `nvidia-smi` fails: recreate with `--nvidia` flag (forgot it at create time, can't add later — `distrobox rm` + recreate).

## Troubleshooting

| symptom                              | check                                                                 |
|--------------------------------------|-----------------------------------------------------------------------|
| `distrobox enter` hangs              | `podman ps -a` — if stopped, `distrobox enter` restarts it            |
| GPU missing in --nvidia container    | Recreate with `--nvidia` flag (cannot patch in place)                 |
| Service didn't auto-start on entry   | Verify `~/.bashrc` has the `service X start` line                     |
| Slow cold start                      | First `apt install` is slow; layers cache for next time               |
| Permission denied on bind mount      | `id` inside — host UID 1000 must equal container UID 1000             |
| Network not working                  | `podman network ls`; restart user podman: `systemctl --user restart podman` |
| Container can't see host display     | `WAYLAND_DISPLAY` must be set; `--nvidia` containers handle this      |

## What NOT to do

- Don't `sudo nh os switch` from inside a container — host nix only
- Don't install dev tools on the host as a "quick fix" — host stays minimal per PLAN.md
- Don't run `apt upgrade` blindly inside — pin versions you care about, the container is meant to be cattle
- Don't keep secrets in container env vars; use the host `gpg-agent` socket bind-mounted automatically by distrobox
- Don't `chown -R` across the host/container boundary — UIDs already match
