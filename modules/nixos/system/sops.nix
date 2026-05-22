{ ... }:

{
  sops = {
    # Age key for system-level secret decryption
    # Generate: age-keygen -o /var/lib/sops-nix/key.txt
    # Or derive from SSH host key: ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = false;

    # GPG: use root's gnupg home for system secrets
    gnupg.home = "/root/.gnupg";
    gnupg.sshKeyPaths = [];
  };
}
