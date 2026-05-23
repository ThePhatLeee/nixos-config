{ config, lib, pkgs, ... }:

let
  auditctl = lib.getExe' pkgs.audit "auditctl";
in
{
  # OOM killer — kill memory hogs before the system locks up
  services.earlyoom = {
    enable               = true;
    freeMemThreshold     = 5;
    freeSwapThreshold    = 5;
    enableNotifications  = true;
  };

  # Journal: cap disk use, auto-vacuum after 2 weeks
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=50M
    MaxRetentionSec=2weeks
  '';

  systemd.coredump.settings.Coredump = {
    Storage       = "none";
    ProcessSizeMax = 0;
  };

  # Sudo — wheel only, short timeout, insults on wrong password
  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      Defaults timestamp_timeout=5
      Defaults insults
    '';
  };

  security.protectKernelImage = true;

  # Open file descriptor and process limits — defaults (1024/32768) are too low
  # for heavy container workloads, Java apps, and parallel builds.
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
    { domain = "*"; type = "soft"; item = "nproc";  value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "nproc";  value = "unlimited"; }
  ];

  security.apparmor = {
    enable   = true;
    packages = [ pkgs.apparmor-profiles ];
  };

  security.audit.enable = true;
  security.audit.backlogLimit = 8192;
  security.audit.rules = [
    # Setuid/setgid escalation — auid>=1000 uses login-uid (stable across su/sudo)
    # auid!=4294967295 excludes daemons that never logged in
    "-a always,exit -F arch=b64 -S execve -F auid>=1000 -F auid!=4294967295 -C uid!=euid -k priv_escalation"

    # Credential and specific config file writes
    "-w /etc/passwd  -p wa -k user_change"
    "-w /etc/shadow  -p wa -k user_change"
    "-w /etc/sudoers -p wa -k sudoers_change"

    # Kernel module loading/unloading
    "-a always,exit -F arch=b64 -S init_module -S finit_module -k module_load"
    "-a always,exit -F arch=b64 -S delete_module -k module_unload"

    # Mount/unmount
    "-a always,exit -F arch=b64 -S mount -S umount2 -k mount_ops"

    # Boot partition writes
    "-w /boot -p wa -k boot_write"

    # SSH authorized keys changes
    "-w ${config.users.users.phatle.home}/.ssh/authorized_keys -p wa -k ssh_keys"

    # Hosts file changes
    "-w /etc/hosts -p wa -k hosts_change"
  ];

  environment.systemPackages = [ pkgs.lynis ];

  boot.kernel.sysctl = {
    # ── Kernel info leaks ─────────────────────────────────────────────
    "kernel.kptr_restrict"       = 2;    # hide kernel pointers from everyone (incl. root)
    "kernel.dmesg_restrict"      = 1;    # dmesg requires CAP_SYSLOG
    "kernel.perf_event_paranoid" = 2;    # perf requires CAP_PERFMON

    # ── ptrace ────────────────────────────────────────────────────────
    "kernel.yama.ptrace_scope"   = 1;    # only parent can ptrace child

    # ── Misc ──────────────────────────────────────────────────────────
    "kernel.sysrq"    = 0;
    "fs.suid_dumpable" = 0;              # no core dumps from setuid

    # ── ASLR ─────────────────────────────────────────────────────────
    "vm.mmap_rnd_bits"        = 32;
    "vm.mmap_rnd_compat_bits" = 16;

    # ── Network hardening ─────────────────────────────────────────────
    "net.ipv4.tcp_syncookies"                 = 1;
    "net.ipv4.conf.all.rp_filter"             = 1;
    "net.ipv4.conf.default.rp_filter"         = 1;
    "net.ipv4.conf.all.accept_redirects"      = 0;
    "net.ipv4.conf.default.accept_redirects"  = 0;
    "net.ipv4.conf.all.secure_redirects"      = 0;
    "net.ipv4.conf.all.send_redirects"        = 0;
    "net.ipv6.conf.all.accept_redirects"      = 0;
    "net.ipv6.conf.default.accept_redirects"  = 0;
    "net.ipv4.conf.all.log_martians"          = 1;

    # ── ICMP ──────────────────────────────────────────────────────────────
    "net.ipv4.icmp_echo_ignore_broadcasts"       = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    # ── Source routing (unused, attack vector) ────────────────────────────
    "net.ipv4.conf.all.accept_source_route"  = 0;
    "net.ipv6.conf.all.accept_source_route"  = 0;

    # ── Not a router ──────────────────────────────────────────────────────
    "net.ipv4.conf.all.forwarding"  = 0;
    "net.ipv6.conf.all.forwarding"  = 0;

    # ── Filesystem hardening ──────────────────────────────────────────────
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks"  = 1;
    "fs.protected_fifos"     = 2;
    "fs.protected_regular"   = 2;

    # ── Full ASLR ─────────────────────────────────────────────────────────
    "kernel.randomize_va_space" = 2;

    # ── BPF hardening ─────────────────────────────────────────────────────
    "kernel.unprivileged_bpf_disabled" = 1;  # no unprivileged BPF programs
    "net.core.bpf_jit_harden"          = 2;  # harden JIT against pointer leaks

    # ── Prevent runtime kernel replacement ────────────────────────────────
    "kernel.kexec_load_disabled" = 1;

    # ── io_uring (CVE-2024-1086 family) ───────────────────────────────────
    # 0 = enabled, 1 = root only, 2 = fully disabled.
    # Lower to 1 if a workload genuinely needs unprivileged io_uring.
    "kernel.io_uring_disabled" = 2;

    # ── User namespaces — pinned so the default can't flip silently ───────
    # podman rootless + distrobox both need this. Don't lower.
    "kernel.unprivileged_userns_clone" = 1;

    # ── Coredump path — belt-and-braces with systemd.coredump above ───────
    "kernel.core_pattern" = "|/bin/false";

    # ── TIOCSTI: classic terminal escape attack vector ────────────────────
    "dev.tty.legacy_tiocsti" = 0;
  };

  # On kernel 7.x, audit_backlog_limit, failure mode (-f), rate (-r), and
  # enforcement level (-e) are all read-only after kernel init (set via cmdline).
  # Strip those admin ops — only -D + rule loading is needed here.
  # ExecStopPost is also cleared: the inherited -e 0 fails the same way.
  systemd.services.audit-rules-nixos.serviceConfig = {
    ExecStart = lib.mkForce (
      pkgs.writeShellScript "audit-load" (
        "${auditctl} -D\n" +
        lib.concatMapStrings (r: "${auditctl} ${r}\n") config.security.audit.rules
      )
    );
    ExecStopPost = lib.mkForce "";
  };
}
