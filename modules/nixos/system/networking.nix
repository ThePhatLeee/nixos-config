{ ... }:
{
  networking.networkmanager = {
    enable      = true;
    dns         = "systemd-resolved";
    wifi.macAddress = "random";
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS        = "1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net";
      DNSSEC     = "yes";
      DNSOverTLS = "opportunistic";
      FallbackDNS = "8.8.8.8#dns.google 8.8.4.4#dns.google";
    };
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable                = true;
    logRefusedConnections = true;
    logRefusedPackets     = true;
  };

  # Runs at priority -1, before the NixOS firewall table (priority 0).
  networking.nftables.tables.pre-filter = {
    family = "inet";
    content = ''
      chain early-drop {
        type filter hook input priority filter - 1; policy accept;

        # Invalid conntrack state — drop before any further processing
        ct state invalid drop

        # ICMP echo-request rate limit — allow burst, then drop
        ip  protocol icmp       icmp type echo-request   limit rate 10/second burst 20 packets accept
        ip  protocol icmp       icmp type echo-request   drop
        ip6 nexthdr  ipv6-icmp  icmpv6 type echo-request limit rate 10/second burst 20 packets accept
        ip6 nexthdr  ipv6-icmp  icmpv6 type echo-request drop
      }
    '';
  };
}
