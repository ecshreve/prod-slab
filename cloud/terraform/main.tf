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
variable "tailscale_token" {}
variable "pub_key" {}

variable "vpc_net" {}
variable "base_name" {}

provider "digitalocean" {
    token = var.do_token
}

resource "digitalocean_vpc" "dodev" {
  name     = "dodev"
  region   = "sfo3"
  ip_range = var.vpc_net
}

resource "digitalocean_ssh_key" "default" {
  name       = "devbox ssh key"
  public_key = var.pub_key
}

resource "digitalocean_droplet" "server" {
  count     = 1
  name      = "${var.base_name}-${count.index}"
  size      = "s-1vcpu-1gb"
  image     = "ubuntu-20-04-x64"
  tags      = [ "dev" ]
  region    = digitalocean_vpc.dodev.region
  vpc_uuid  = digitalocean_vpc.dodev.id
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]
  user_data = templatefile("${path.module}/userdata.tpl", {
    tailscale_key = var.tailscale_token
  })
}

resource "digitalocean_project" "slabnet" {
  name        = "devbox"
  description = "A project for the cloud devbox"
  resources   = digitalocean_droplet.server.*.urn
}

output "public_ip" {
  value = digitalocean_droplet.server.*.ipv4_address
}

output "private_ip" {
  value = digitalocean_droplet.server.*.ipv4_address_private 
}
