---
name: sysadmin
description: Use for Linux administration, NixOS server setup, systemd, networking, storage, monitoring, or infrastructure work. Triggers on: systemd, service, cron, nginx, firewall, disk, mount, kernel, server, infrastructure, monitoring, logs, journalctl.
---

# Sysadmin — Linux / NixOS

## Systemd

```bash
# Unit management
systemctl status|start|stop|restart|reload <unit>
systemctl enable|disable <unit>          # persistent across boots
systemctl daemon-reload                   # after editing unit files
systemctl --failed                        # show failed units
journalctl -u <unit> -f                  # follow unit logs
journalctl -u <unit> --since "10 min ago"
journalctl -p err -b                     # errors since last boot

# Socket activation — service starts on first connection
# Timer — systemd replacement for cron
systemctl list-timers --all
```

## NixOS service pattern

```nix
systemd.services.myapp = {
  description = "My Application";
  after  = [ "network.target" "postgresql.service" ];
  wants  = [ "postgresql.service" ];
  wantedBy = [ "multi-user.target" ];

  serviceConfig = {
    User  = "myapp";
    Group = "myapp";
    ExecStart  = "${pkgs.myapp}/bin/myapp --config /etc/myapp/config.toml";
    Restart    = "on-failure";
    RestartSec = 5;

    # Security hardening
    NoNewPrivileges   = true;
    PrivateTmp        = true;
    ProtectSystem     = "strict";
    ProtectHome       = true;
    ReadWritePaths    = [ "/var/lib/myapp" ];
    CapabilityBoundingSet = "";
    SystemCallFilter  = "@system-service";
  };
};
```

## Networking

```bash
# Show interfaces and IPs
ip addr show
ip route show

# nftables rules (NixOS — edit networking.nix, don't run nft directly)
nft list ruleset

# DNS
resolvectl status
dig +short @1.1.1.1 example.com
ss -tlnp                     # listening TCP ports
ss -ulnp                     # listening UDP ports
```

## Storage

```bash
# Disk usage
df -h                        # filesystem usage
du -sh /var/*                # directory sizes
lsblk -f                     # block devices with filesystems and UUIDs
blkid                        # partition UUIDs

# BTRFS (this system)
btrfs filesystem usage /
btrfs subvolume list /
btrfs scrub start /          # integrity check
btrfs balance start --bg /   # rebalance (run occasionally)

# Check LUKS
cryptsetup status cryptroot
cryptsetup luksDump /dev/nvme0n1p3
```

## Process management

```bash
ps aux --sort=-%cpu | head -10    # top CPU consumers
ps aux --sort=-%mem | head -10    # top memory consumers
lsof -i :8080                     # what's using port 8080
strace -p PID                     # syscall trace
ltrace -p PID                     # library call trace
```

## Log analysis

```bash
# journald — structured logs
journalctl -b                     # current boot
journalctl -b -1                  # previous boot
journalctl --since yesterday
journalctl -o json-pretty -n 50

# Auth / security events
journalctl -u sshd -f
journalctl SYSLOG_IDENTIFIER=sudo

# grep patterns from logs
journalctl | grep -E "error|fail|denied" -i
```

## Nginx (NixOS)

```nix
services.nginx = {
  enable = true;
  recommendedTlsSettings     = true;
  recommendedOptimisation    = true;
  recommendedGzipSettings    = true;
  recommendedProxySettings   = true;

  virtualHosts."example.com" = {
    enableACME = true;
    forceSSL   = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
    };
  };
};
security.acme = {
  acceptTerms = true;
  defaults.email = "admin@example.com";
};
```

## Performance investigation

```bash
# System overview
vmstat 1 5             # CPU, memory, swap, IO
iostat -xz 1 5         # disk IO per device
free -h                # memory + swap usage

# Network throughput
iftop -i eth0          # per-connection bandwidth

# CPU profiling
perf top               # live CPU hotspots
perf record -g ./app   # record with call graph
perf report            # analyze

# Memory
valgrind --tool=massif ./app   # heap profiling
```

## Backups (restic pattern)

```nix
services.restic.backups.daily = {
  paths              = [ "/home" "/var/lib" "/etc" ];
  exclude            = [ "/home/*/.cache" "/var/lib/docker" ];
  repository         = "s3:s3.amazonaws.com/bucket/hostname";
  passwordFile       = config.sops.secrets.restic-password.path;
  s3CredentialsFile  = config.sops.secrets.aws-creds.path;
  timerConfig.OnCalendar = "daily";
  pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
};
```

## Security baseline (NixOS host)

```nix
# Already in this config — do not remove
boot.initrd.systemd.enable = true;    # TPM2 unlock
security.apparmor.enable   = true;    # complain mode first, enforce after 2 weeks
services.fail2ban.enable   = true;    # SSH brute force protection
networking.firewall.enable = true;    # nftables-backed
```
