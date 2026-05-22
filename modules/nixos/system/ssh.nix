{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin        = "no";
      AllowUsers             = [ "phatle" ];
      MaxAuthTries           = 3;
      LoginGraceTime         = 30;
      X11Forwarding          = false;
      AllowTcpForwarding     = "no";
      AllowAgentForwarding   = false;
      GatewayPorts           = "no";
      ClientAliveInterval    = 300;
      ClientAliveCountMax    = 2;
    };
    # Port 22 by default — change here and in firewall if you want non-standard
  };

  services.fail2ban = {
    enable   = true;
    maxretry = 3;
    bantime  = "1h";
    jails.sshd.settings = {
      enabled  = true;
      port     = "ssh";
      maxretry = 3;
    };
  };
}
