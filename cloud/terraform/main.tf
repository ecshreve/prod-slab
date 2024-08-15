terraform {
  cloud {
    organization = "slablan"

    workspaces {
      name = "digitalocean-dev"
    }
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "ts_token" {}
variable "ssh_pub_key" {}
variable "server_name" {}

provider "digitalocean" {
    token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "do ssh key"
  public_key = var.ssh_pub_key
}

resource "digitalocean_droplet" "server" {
  count      = 1
  name       = "${var.server_name}-${count.index}"
  size       = "s-2vcpu-2gb"
  image      = "ubuntu-20-04-x64"
  tags       = [ "dev" ]
  region     = "sfo3"
  monitoring = true
  ssh_keys   = [digitalocean_ssh_key.default.fingerprint]
  user_data  = templatefile("${path.module}/userdata.tpl", {
    ssh_authorized_key = var.ssh_pub_key
    tailscale_key = var.ts_token
  })
}

output "public_ip" {
  value = digitalocean_droplet.server.*.ipv4_address
}

output "private_ip" {
  value = digitalocean_droplet.server.*.ipv4_address_private 
}
