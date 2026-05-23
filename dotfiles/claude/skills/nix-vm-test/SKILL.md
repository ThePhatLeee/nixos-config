---
name: nix-vm-test
description: Use for testing NixOS modules in QEMU before nh os switch, writing module integration tests, validating module behavior reproducibly. Saves the rebuild cycle on the laptop for risky changes. Auto-triggers on: nixos test, nixos-test-driver, module test, vm test, runInteractiveNixOSTest.
---

# NixOS VM Testing

Test a NixOS module in a QEMU VM driven by a Python test harness — without touching the host. Use for: security-critical module changes (security.nix, ssh.nix, usbguard.nix, tpm.nix), risky service config, anything where a broken rebuild means manual recovery.

## Two flavors

| flavor                   | when                                  |
|--------------------------|---------------------------------------|
| `nixosTest`              | CI, eval-only, no GUI                 |
| `runInteractiveNixOSTest`| Local debug with a GUI window         |

## Minimal test (eval + boot)

`tests/security.nix`:
```nix
{ pkgs, ... }:
pkgs.nixosTest {
  name = "security-module";
  nodes.machine = { pkgs, ... }: {
    imports = [ ../modules/nixos/system/security.nix ];

    # Minimal extras the module assumes
    users.users.phatle = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # earlyoom is enabled
    machine.succeed("systemctl is-active earlyoom")

    # AppArmor is loaded
    machine.succeed("aa-status --enabled")

    # Sysctls applied
    machine.succeed("sysctl kernel.kptr_restrict | grep -q '= 2'")
    machine.succeed("sysctl kernel.io_uring_disabled | grep -q '= 2'")
    machine.succeed("sysctl kernel.unprivileged_userns_clone | grep -q '= 1'")

    # Audit service is running
    machine.succeed("systemctl is-active auditd")
    machine.succeed("auditctl -l | grep -q priv_escalation")
  '';
}
```

Run it:
```bash
nix build -L .#checks.x86_64-linux.security
# or for interactive
nix run -L .#checks.x86_64-linux.security.driverInteractive
```

## Wire into flake.nix

```nix
outputs = { self, nixpkgs, ... }@inputs: let
  system = "x86_64-linux";
  pkgs   = nixpkgs.legacyPackages.${system};
in {
  # existing stuff...

  checks.${system} = {
    security = import ./tests/security.nix { inherit pkgs; };
    ssh      = import ./tests/ssh.nix      { inherit pkgs; };
    usbguard = import ./tests/usbguard.nix { inherit pkgs; };
  };
};
```

Then `nix flake check` runs all of them.

## Multi-node test (client + server)

```nix
pkgs.nixosTest {
  name = "ssh-server";
  nodes = {
    server = { ... }: {
      services.openssh.enable = true;
      services.openssh.settings.PermitRootLogin = "no";
      services.fail2ban.enable = true;
      users.users.alice = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
      };
    };
    client = { ... }: { environment.systemPackages = [ pkgs.openssh ]; };
  };
  testScript = ''
    start_all()
    server.wait_for_unit("sshd.service")
    server.wait_for_open_port(22)
    client.wait_until_succeeds("ssh -o StrictHostKeyChecking=no alice@server true")
    # Negative: root login must fail
    client.fail("ssh -o StrictHostKeyChecking=no root@server true")
    # fail2ban kicks in after brute force
    for _ in range(6):
        client.fail("sshpass -p wrong ssh alice@server true 2>&1")
    server.succeed("fail2ban-client status sshd | grep -q 'Banned IP'")
  '';
}
```

## TestScript Python API (the useful 80%)

```python
machine.wait_for_unit("name.service")       # systemd unit active
machine.wait_for_open_port(80)              # TCP port listening
machine.wait_for_x()                        # graphical session ready
machine.succeed("command")                  # exit 0; returns stdout
machine.fail("command")                     # non-zero exit; returns stdout
machine.execute("command")                  # (status, stdout) tuple — no assertion
machine.shell_interact()                    # drop into a shell from driver
machine.screenshot("hello")                 # save screenshot
machine.send_chars("text\n")                # type into terminal
machine.systemctl("restart name.service")
machine.copy_from_host(src, dst)            # push file in
machine.copy_from_vm(src)                   # pull file out
```

Multi-node:
```python
start_all()                                 # boot all nodes
server.wait_for_unit("sshd")
client.succeed("ssh server true")
```

## What's worth testing

| Module                    | Test |
|---------------------------|------|
| `security.nix`            | Sysctls applied, audit rules loaded, AppArmor active |
| `ssh.nix`                 | Key-only auth, root denied, fail2ban bans after N attempts |
| `usbguard.nix`            | Service running, default policy is "block", allowlist parsed |
| `tpm.nix`                 | tpm2-tools available, crypttab options present (TPM hardware not in VM — limited) |
| `containers.nix`          | Podman daemon runs, image pull works |
| `snapshots.nix`           | snapper config valid, timers active |

What's NOT worth testing:
- Hardware-specific stuff (NVIDIA, TPM, USBGuard hashes — none of this exists in VM)
- Anything that needs network out (build hits cache anyway)
- Boot loader (lanzaboote — VM uses different boot path)

## Debugging a failing test

```bash
nix run .#checks.x86_64-linux.security.driverInteractive
# In the Python REPL that opens:
>>> machine.start()
>>> machine.shell_interact()
# Then inside the VM shell, poke around manually
```

Or run with `--verbose`:
```bash
nix build -L .#checks.x86_64-linux.security 2>&1 | tee test.log
```

## Anti-patterns

- Testing module *defaults* — that tests nixpkgs, not your config; test your *changes*
- One mega-test for the whole system — split per module, parallelizable
- `machine.succeed("sleep 30; check")` — use `wait_until_succeeds` instead
- Not asserting negatives — "ssh as root works" tells you nothing if it shouldn't even try
- VM tests that depend on internet — sandbox blocks it; mock or cache
- Forgetting to add the test to `checks` — orphan file that no one runs
