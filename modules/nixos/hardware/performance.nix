{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [ "tcp_bbr" ];

  boot.kernel.sysctl = {
    # ── Virtual memory ────────────────────────────────────────────────
    # Low swappiness: zram handles primary swap, disk swapfile is last resort
    "vm.swappiness"                = 10;
    # Absolute dirty byte thresholds — more predictable writeback than ratio-based
    # on large-RAM machines (ratio=10% of 32GB = 3.2GB stall before flush)
    "vm.dirty_ratio"               = 0;
    "vm.dirty_background_ratio"    = 0;
    "vm.dirty_bytes"               = 268435456;   # 256MB: start writeback
    "vm.dirty_background_bytes"    = 67108864;    # 64MB: background flush
    "vm.vfs_cache_pressure"        = 50;
    # Keep more free memory headroom — reduces kswapd wakeup frequency
    "vm.watermark_scale_factor"    = 125;
    # Disable watermark boost — prevents sudden large kswapd reclaim spikes
    "vm.watermark_boost_factor"    = 0;
    # Groups processes by session — desktop apps get equal time slice vs build jobs
    "kernel.sched_autogroup_enable" = 1;
    # Raise pid ceiling — heavy container+build workloads can exhaust 32768 default
    "kernel.pid_max"               = 4194304;

    # ── Network ───────────────────────────────────────────────────────
    # BBR congestion control + fair queueing — better throughput/latency
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc"          = "fq";
    # Larger socket buffers (128 MiB) for high-bandwidth transfers
    "net.core.rmem_max"           = 134217728;
    "net.core.wmem_max"           = 134217728;
    "net.ipv4.tcp_rmem"           = "4096 87380 134217728";
    "net.ipv4.tcp_wmem"           = "4096 65536 134217728";

    # ── inotify ───────────────────────────────────────────────────────
    # Dev tooling (vite, webpack, watchman) needs large watch limits
    "fs.inotify.max_user_watches"   = 524288;
    "fs.inotify.max_user_instances" = 512;

    # ── Misc ──────────────────────────────────────────────────────────
    "kernel.nmi_watchdog" = 0;    # disable NMI watchdog — saves ~1 % power

    # ── Swap ──────────────────────────────────────────────────────────
    "vm.page-cluster" = 0;        # SSD/zram: no sequential readahead on swap

    # ── Memory ────────────────────────────────────────────────────────
    # Java, containers (Elasticsearch), some games need high map count
    "vm.max_map_count"              = 1048576;
    # Disable proactive compaction — it causes latency spikes on desktop
    "vm.compaction_proactiveness"   = 0;

    # ── Network extras ────────────────────────────────────────────────
    # TCP Fast Open: send data on SYN (client+server) — reduces RTT for repeat connections
    "net.ipv4.tcp_fastopen"              = 3;
    # PLPMTUD: probe for optimal MTU on lossy paths instead of assuming 1500
    "net.ipv4.tcp_mtu_probing"           = 1;
    # Larger NIC receive queue — prevents drops under bursty traffic
    "net.core.netdev_max_backlog"        = 5000;
    # Don't reset congestion window after idle — faster resumption of SSH/API sessions
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    # Timestamps leak uptime and waste 12B/packet — marginal benefit on private LAN
    "net.ipv4.tcp_timestamps"            = 0;
  };

  boot.kernelParams = [
    "transparent_hugepage=madvise"
    # Intel display: Panel Self Refresh (biggest battery save) + Framebuffer Compression
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
  ];

  # I/O schedulers via udev:
  # NVMe has hardware queuing — "none" passes requests directly to the drive.
  # SATA SSD: mq-deadline gives low latency without the overhead of bfq.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*",      ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';
}
