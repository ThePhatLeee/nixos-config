---
name: ict
description: Use for IT support, Windows/Active Directory, networking fundamentals, hardware troubleshooting, helpdesk scenarios, or general ICT problems. Triggers on: Windows, Active Directory, Group Policy, DNS, DHCP, domain, helpdesk, IT support, hardware, driver, network troubleshooting.
---

# ICT / IT Support

## Troubleshooting methodology

Always: gather → reproduce → isolate → fix → verify → document.
Never skip "reproduce" — solving a problem you can't see is guesswork.

```
1. What exactly is the error / symptom?
2. When did it start? What changed?
3. Who else is affected? One user, one group, all users?
4. Network problem? → Layer 1 → 2 → 3 → 4 (Physical → Data → Network → Transport)
5. Application problem? → Logs first, reproduce second
```

## Windows — common fixes

```powershell
# DNS flush + re-register
ipconfig /flushdns
ipconfig /registerdns
ipconfig /release && ipconfig /renew

# Reset network stack
netsh winsock reset
netsh int ip reset
netsh advfirewall reset

# Clear credentials
cmdkey /list
cmdkey /delete:target

# Group Policy force refresh
gpupdate /force

# Check GP result for a user
gpresult /R /user DOMAIN\username /scope USER

# SFC + DISM — system file repair
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth

# Event logs — look here first
Get-EventLog -LogName System   -Newest 50 -EntryType Error,Warning
Get-EventLog -LogName Security -Newest 20
```

## Active Directory

```powershell
# User management
Get-ADUser -Identity jsmith -Properties *
New-ADUser -Name "John Smith" -SamAccountName jsmith -UserPrincipalName "jsmith@domain.com" -AccountPassword (ConvertTo-SecureString "Temp1234!" -AsPlainText -Force) -Enabled $true
Set-ADUser -Identity jsmith -Department "IT" -Manager manager
Disable-ADAccount -Identity jsmith
Move-ADObject -Identity $userDN -TargetPath "OU=Disabled,DC=domain,DC=com"

# Group management
Add-ADGroupMember -Identity "IT Department" -Members jsmith
Get-ADGroupMember -Identity "Domain Admins" | Select Name, SamAccountName

# Find locked accounts / unlock
Search-ADAccount -LockedOut | Select Name, LastLogonDate
Unlock-ADAccount -Identity jsmith

# Password reset
Set-ADAccountPassword -Identity jsmith -NewPassword (ConvertTo-SecureString "NewPass1!" -AsPlainText -Force) -Reset
Set-ADUser -Identity jsmith -ChangePasswordAtLogon $true

# Find computers
Get-ADComputer -Filter "LastLogonDate -lt (Get-Date).AddDays(-90)" -Properties LastLogonDate
```

## Network diagnostics

```bash
# Linux / Mac
ping -c 4 8.8.8.8               # ICMP reachability
traceroute 8.8.8.8              # path to destination
mtr 8.8.8.8                     # continuous traceroute
nslookup example.com 8.8.8.8   # DNS query via specific server
dig +trace example.com          # full DNS resolution chain
curl -v https://example.com     # HTTP with headers
nc -zv host 443                 # TCP port check

# Windows
Test-NetConnection -ComputerName example.com -Port 443
Resolve-DnsName example.com
Test-Connection 8.8.8.8 -Count 4
```

## DHCP / DNS

```
Client not getting IP:
1. Check cable / Wi-Fi association
2. ipconfig /release && /renew
3. Check DHCP server: Event Log → System → DHCP source
4. Check DHCP scope: exhausted? excluded ranges overlapping?
5. Check firewall: UDP 67/68 not blocked

DNS not resolving:
1. Can ping IP but not name? → DNS issue confirmed
2. nslookup fails with primary, works with 8.8.8.8? → Internal DNS problem
3. Check DNS server logs, check forwarders
4. Check conditional forwarders for split-brain DNS
```

## Remote support

```powershell
# Enable PSRemoting (WinRM)
Enable-PSRemoting -Force

# Remote session
Enter-PSSession -ComputerName WORKSTATION01 -Credential DOMAIN\admin

# Run command on remote machine
Invoke-Command -ComputerName WORKSTATION01 -ScriptBlock { Get-Process }

# Copy files
Copy-Item \\WORKSTATION01\c$\logs\app.log C:\temp\

# Remote desktop from CLI
mstsc /v:WORKSTATION01
```

## Hardware diagnostics

```
Memory: Windows Memory Diagnostic / memtest86+
Disk: S.M.A.R.T. via CrystalDiskInfo, smartctl (Linux)
CPU: Prime95 (stability test), HWiNFO64 (temps)
GPU: GPU-Z, OCCT, or games crashing = driver or thermal issue
PSU: swap test or use power supply tester
Thermal paste: reapply if CPU temps >90°C at load
```

```bash
# Linux disk health
smartctl -a /dev/sda
smartctl -t short /dev/sda    # run short test

# Linux memory test
memtester 1G 1    # test 1GB of RAM once
```

## Printer troubleshooting

```
1. Print spooler: services.msc → Print Spooler → Restart
2. Clear spooler: Stop spooler → del C:\Windows\System32\spool\PRINTERS\* → Start
3. Driver: uninstall all → reinstall manufacturer driver (not Windows Update driver)
4. Network printer: ping printer IP, check port 9100 (raw print), 631 (IPP)
5. Permissions: check share permissions + NTFS permissions on print share
```

## Documentation / ticket hygiene

- Always record: what was the issue, what was tried, what fixed it
- Reproducible steps in tickets — not "it broke"
- Before closing: verify with the user, not just yourself
- Recurring issues: escalate for root cause, not just break/fix
