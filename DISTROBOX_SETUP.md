# Distrobox Container Setup

Run creation commands on host. Run install commands inside each container via `distrobox enter <name>`.

---

## Create all containers

```bash
distrobox create --name frontend  --image ubuntu:24.04 --nvidia
distrobox create --name backend   --image ubuntu:24.04
distrobox create --name fullstack --image ubuntu:24.04 --nvidia
distrobox create --name it        --image ubuntu:24.04
```

---

## frontend

Stack: Node.js · pnpm · bun · TypeScript · Vite · Three.js/WebGL (npm packages per project)

```bash
distrobox enter frontend
```

```bash
# Node.js via nvm (manages versions easily)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts
nvm alias default node

# Global package managers + tooling
npm install -g pnpm bun typescript

# Verify
node --version && pnpm --version && bun --version
```

> React, Tailwind, Vite, Three.js etc. are per-project — install via pnpm/bun in the project directory.

---

## backend

Stack: PHP/Laravel · Python · Java · .NET · Go · Rust · C++ · MySQL · PostgreSQL · Redis

```bash
distrobox enter backend
```

```bash
# ── Base tools ────────────────────────────────────────────────────────
sudo apt update && sudo apt install -y \
  curl wget git build-essential software-properties-common \
  libssl-dev pkg-config

# ── PHP 8.3 + Laravel ─────────────────────────────────────────────────
sudo add-apt-repository ppa:ondrej/php -y && sudo apt update
sudo apt install -y \
  php8.3 php8.3-cli php8.3-mbstring php8.3-xml php8.3-curl \
  php8.3-zip php8.3-pgsql php8.3-mysql php8.3-gd php8.3-intl \
  php8.3-bcmath php8.3-redis php8.3-sqlite3
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer global require laravel/installer
echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc

# ── Python ────────────────────────────────────────────────────────────
sudo apt install -y python3 python3-pip python3-venv
pip install uv  # fast pip/venv replacement

# ── Java (OpenJDK 21 LTS) ─────────────────────────────────────────────
sudo apt install -y openjdk-21-jdk maven gradle
java -version

# ── .NET 9 ────────────────────────────────────────────────────────────
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O ms.deb
sudo dpkg -i ms.deb && rm ms.deb
sudo apt update && sudo apt install -y dotnet-sdk-9.0
dotnet --version

# ── Go ────────────────────────────────────────────────────────────────
GO_VERSION=1.23.4
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
go version

# ── Rust ──────────────────────────────────────────────────────────────
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustup component add rust-analyzer clippy rustfmt
rustup target add wasm32-unknown-unknown
cargo --version

# ── C++ ───────────────────────────────────────────────────────────────
sudo apt install -y gcc g++ clang cmake ninja-build gdb lldb valgrind

# ── MySQL (MariaDB) + PostgreSQL + Redis ──────────────────────────────
sudo apt install -y mariadb-server postgresql postgresql-contrib redis-server

# Start services (inside container — no systemd, use service command)
sudo service mariadb start
sudo service postgresql start
sudo service redis-server start

# Make them start automatically in container (add to ~/.bashrc)
echo 'sudo service mariadb start > /dev/null 2>&1' >> ~/.bashrc
echo 'sudo service postgresql start > /dev/null 2>&1' >> ~/.bashrc
echo 'sudo service redis-server start > /dev/null 2>&1' >> ~/.bashrc

# ── DB clients ────────────────────────────────────────────────────────
sudo apt install -y mysql-client postgresql-client

# ── Final source ──────────────────────────────────────────────────────
source ~/.bashrc
```

---

## fullstack

Stack: everything from frontend + backend combined.

```bash
distrobox enter fullstack
```

Run all commands from **frontend** section, then all commands from **backend** section.

---

## it

Stack: Ansible · network tools · AD/LDAP/Kerberos · PowerShell · Python automation · IT scripting

> Security testing (Metasploit, Burp, exploit dev) goes in the **Kali VM**, not here.
> This container is for infrastructure management, monitoring, and automation.

```bash
distrobox enter it
```

```bash
# ── Base ──────────────────────────────────────────────────────────────
sudo apt update && sudo apt install -y \
  curl wget git python3 python3-pip software-properties-common

# ── Ansible ───────────────────────────────────────────────────────────
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version

# ── Network tools ─────────────────────────────────────────────────────
sudo apt install -y \
  nmap wireshark tcpdump iperf3 \
  traceroute mtr fping netdiscover \
  bind9-utils sshuttle whois \
  openssl openssh-client sshpass \
  net-tools iproute2

# ── AD / LDAP / Kerberos / Windows interop ────────────────────────────
sudo apt install -y \
  ldap-utils \
  smbclient \
  krb5-user \
  winbind \
  freeradius-utils

# ── PowerShell Core ───────────────────────────────────────────────────
wget -q "https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb" -O ms.deb
sudo dpkg -i ms.deb && rm ms.deb
sudo apt update && sudo apt install -y powershell
pwsh --version

# ── Python network automation ─────────────────────────────────────────
pip install paramiko netmiko napalm requests scapy pywinrm ldap3

# ── Scripting utilities ───────────────────────────────────────────────
sudo apt install -y jq rsync

# yq (YAML processor — newer than apt version)
sudo wget -qO /usr/local/bin/yq \
  https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq
yq --version
```

---

## VMs (via virt-manager / libvirtd)

Host already has libvirtd + virt-manager enabled. Download ISOs and create VMs normally.

### Kali Linux

- **Purpose**: security testing, CTF, exploit dev, Burp, Metasploit, forensics
- **Why VM not container**: Kali needs a full kernel, custom tools, and isolation
- Download: https://www.kali.org/get-kali/#kali-virtual-machines (pre-built QEMU/KVM image)
- Recommended: 4 CPU, 8 GB RAM, 80 GB disk, SPICE display
- Enable USB passthrough via spice for hardware dongles if needed

```bash
# Import pre-built Kali QEMU image (fastest)
virt-install \
  --name kali \
  --ram 8192 \
  --vcpus 4 \
  --disk path=~/VMs/kali-linux-qemu.qcow2,format=qcow2 \
  --import \
  --os-variant debiantesting \
  --graphics spice \
  --noautoconsole
```

### Windows 10/11

- **Purpose**: AD lab, Windows-only tools, RDP testing, Office
- Download: https://www.microsoft.com/software-download/windows11
- Recommended: 4 CPU, 8 GB RAM, 60 GB disk
- Enable swtpm (TPM 2.0) — already configured in virtualization.nix
- Install VirtIO drivers for disk/network performance: https://github.com/virtio-win/virtio-win-pkg-scripts

```bash
# Create Windows VM (use virt-manager GUI — easier for Windows UEFI + TPM setup)
virt-manager
```

> For AD lab: promote Windows Server to domain controller, then join test clients.
> Connect from host or `it` container using `smbclient`, `ldapsearch`, `pwsh`, or RDP via `xfreerdp`.

---

## VSCode Dev Containers

Install the **Dev Containers** extension on host VSCode, then:

1. Open a project folder
2. `Ctrl+Shift+P` → "Dev Containers: Attach to Running Container"
3. Select the container (`frontend` / `backend` / `fullstack`)
4. VSCode connects — install your extensions inside the container

For automatic extension installs per container, add a `.devcontainer/devcontainer.json` to your project:

```json
{
  "name": "backend",
  "extensions": [
    "bmewburn.vscode-intelephense-client",
    "ms-python.python",
    "golang.go"
  ]
}
```
