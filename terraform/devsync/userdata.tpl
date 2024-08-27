#cloud-config
---
users:
  - name: eric
    ssh-authorized-keys:
      - ${ssh_authorized_key}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
apt:
  sources:
    tailscale.list:
      source: deb https://pkgs.tailscale.com/stable/ubuntu focal main
      keyid: 2596A99EAAB33821893C0A79458CA832957F5868
packages:
  - tailscale
runcmd:
  - [tailscale, up, --auth-key, ${tailscale_key}, --accept-routes, --accept-dns, --ssh]