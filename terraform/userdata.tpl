#cloud-config
---
apt:
  sources:
    tailscale.list:
      source: deb https://pkgs.tailscale.com/stable/ubuntu focal main
      keyid: 2596A99EAAB33821893C0A79458CA832957F5868
packages: 
  - tailscale
runcmd:
  - [tailscale, up, -authkey, ${tailscale_key}]