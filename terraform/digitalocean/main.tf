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

variable "region" {
  type = string
  description = "the region where the resources exist"
  default = "sfo3"
}

variable "do_token" {
  type = string
  description = "the digitalocean token"
}

variable "ts_token" {
  type = string
  description = "the tailscale auth token"
}

provider "digitalocean" {
    token = var.do_token
}

data "digitalocean_ssh_key" "default" {
  name = "ecs"
}

data "digitalocean_volume" "vol" {
  name   = "prod-slab-vol"
  region = var.region
}

resource "digitalocean_droplet" "server" {
  name       = "cloudbox"
  size       = "s-2vcpu-4gb"
  image      = "ubuntu-20-04-x64"
  tags       = [ "dev" ]
  region     = var.region
  monitoring = true
  ipv6       = false
  volume_ids = [data.digitalocean_volume.vol.id]
  ssh_keys   = [data.digitalocean_ssh_key.default.id]
  user_data  = templatefile("${path.module}/userdata.tpl", {
    ssh_authorized_key = data.digitalocean_ssh_key.default.public_key
    tailscale_key = var.ts_token
  })
}

output "do_public_ip" {
  value = digitalocean_droplet.server.*.ipv4_address
}

output "do_private_ip" {
  value = digitalocean_droplet.server.*.ipv4_address_private 
}



