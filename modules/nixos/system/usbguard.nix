{ pkgs, ... }:

# USBGuard — allowlist-based USB device control.
# Rules generated from: sudo usbguard generate-policy
# To update after adding a new device:
#   sudo usbguard generate-policy   (with all devices plugged in)
#   replace the rules string below
{
  environment.systemPackages = [ pkgs.usbguard ];

  services.usbguard = {
    enable = true;
    rules = ''
      # ── Internal USB controllers (xHCI root hubs) ─────────────────────────────
      allow id 1d6b:0002 serial "0000:00:0d.0" name "xHCI Host Controller" hash "d3YN7OD60Ggqc9hClW0/al6tlFEshidDnQKzZRRk410=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:00:0d.0" name "xHCI Host Controller" hash "4Q3Ski/Lqi8RbTFr10zFlIpagY9AKVMszyzBQJVKE+c=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" hash "prM+Jby/bFHCn2lNjQdAMbgc6tse3xVx+hZwjOPHSdQ=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""

      # ── Built-in devices ──────────────────────────────────────────────────────
      # Goodix fingerprint reader (in-display)
      allow id 27c6:63ac serial "UID99E2568F_XXXX_MOC_B0" name "Goodix USB2.0 MISC" hash "GSzSwC0ZVqzoalrNX7dlV9RUp+cQ2RYz5i4fR291brk=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface ff:00:00 with-connect-type "not used"
      # Integrated webcam
      allow id 0c45:6a11 serial "" name "Integrated_Webcam_HD" hash "eISuCWzo6PATLv7seS93zdSynaxDyG4Iv8IbjL58KaU=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-11" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 } with-connect-type "not used"
      # Intel AX201 Bluetooth
      allow id 8087:0026 serial "" name "" hash "Z5csNGxiUukPPZwSHPyUqpVCNagsfOSSNL2CfXhw4IY=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-14" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"

      # ── Dell DA310 USB-C dock + its downstream devices ─────────────────────────
      # Frescologic USB 2.0 hub (inside dock)
      allow id 1d5c:5510 serial "" name "Frescologic USB2.0 HUB" hash "cB72sR3VCq7yCpcVuU+X4U0Ezp81k0UJ2X1BHerjtII=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-3" with-interface { 09:00:01 09:00:02 } with-connect-type "hotplug"
      # Frescologic USB 3.1 hub (inside dock)
      allow id 1d5c:5500 serial "" name "Frescologic USB3.1Gen2 HUB" hash "yBuQyxOfgH2J/5zcIOn3B2YSVkZnuU1jYlaheyWp23Q=" parent-hash "prM+Jby/bFHCn2lNjQdAMbgc6tse3xVx+hZwjOPHSdQ=" via-port "4-1" with-interface 09:00:00 with-connect-type "hotplug"
      # Dell DA310 dock controller
      allow id 413c:c010 serial "11AD1D0A09E32D111C200B00" name "Dell DA310" hash "RZFZ9Yovbz1Kud/4rXV1OB/HrNDkjR/AQb8SBuuqHy4=" parent-hash "cB72sR3VCq7yCpcVuU+X4U0Ezp81k0UJ2X1BHerjtII=" with-interface { 11:00:00 ff:03:00 } with-connect-type "unknown"
      # Realtek USB Ethernet (via dock)
      allow id 0bda:8153 serial "001000001" name "USB 10/100/1000 LAN" hash "y8c/mp5bRTGXYVTDuNzIBwhRaTbSU30I2rp5Y7ZfR8o=" parent-hash "yBuQyxOfgH2J/5zcIOn3B2YSVkZnuU1jYlaheyWp23Q=" with-interface { ff:ff:00 02:06:00 0a:00:00 0a:00:00 } with-connect-type "unknown"

      # ── External peripherals ──────────────────────────────────────────────────
      # Logitech C922 Pro webcam
      allow id 046d:085c serial "E76C261F" name "C922 Pro Stream Webcam" hash "PTlRzTT2b6agZs3gO/USXSWb6r7hu0D1WngxUnaUXQI=" parent-hash "cB72sR3VCq7yCpcVuU+X4U0Ezp81k0UJ2X1BHerjtII=" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 } with-connect-type "unknown"
      # SanDisk 3.2Gen1 USB drive (serial-locked to this specific drive)
      allow id 0781:55ab serial "00003017080425211244" name " SanDisk 3.2Gen1" hash "dj53Y4+AVQcLgQTb8/AxtnTyRt9AFR6zGNeXuhqIcC4=" parent-hash "4Q3Ski/Lqi8RbTFr10zFlIpagY9AKVMszyzBQJVKE+c=" with-interface { 08:06:50 08:06:62 } with-connect-type "hotplug"
    '';
  };
}
