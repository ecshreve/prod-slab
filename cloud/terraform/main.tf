terraform {
  cloud {
    organization = "slablan"

    workspaces {
      name = "prod-slab"
    }
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4.2"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

variable "do_tok" {}
variable "ts_tok" {}
variable "ssh_pub_key" {}
variable "server_name" {}

provider "digitalocean" {
    token = var.do_tok
}

resource "digitalocean_ssh_key" "default" {
  name       = "do ssh key"
  public_key = var.ssh_pub_key
}

data "digitalocean_volume" "vol" {
  name   = "prod-slab-vol"
  region = "sfo3"
}

resource "digitalocean_droplet" "server" {
  count      = 1
  name       = "${var.server_name}${count.index}"
  size       = "s-2vcpu-4gb"
  image      = "ubuntu-20-04-x64"
  tags       = [ "dev" ]
  region     = "sfo3"
  monitoring = true
  ipv6       = true
  volume_ids = [data.digitalocean_volume.vol.id]
  ssh_keys   = [digitalocean_ssh_key.default.fingerprint]
  user_data  = templatefile("${path.module}/userdata.tpl", {
    ssh_authorized_key = var.ssh_pub_key
    tailscale_key = var.ts_tok
  })
}

output "public_ip" {
  value = digitalocean_droplet.server.*.ipv4_address
}

output "private_ip" {
  value = digitalocean_droplet.server.*.ipv4_address_private 
}

resource "local_sensitive_file" "userdata" {
  content = templatefile("${path.module}/userdata.tpl", {
    ssh_authorized_key = var.ssh_pub_key
    tailscale_key = var.ts_tok
  })
  
  filename = "${path.module}/userdata.cfg"
}

resource "multipass_instance" "vm" {
    count = 1
    name  = "srv"
    image = "focal"
    cpus  = 4
    memory = "8G"
    disk = "20G"
    cloudinit_file = local_sensitive_file.userdata.filename
}
