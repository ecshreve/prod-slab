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

variable "do_token" {}
variable "ts_token" {}
variable "do_ssh_key_name" { default = "ecs" }
variable "region" { default = "sfo3" }
variable "cpus" { default = 2 }
variable "memory" { default = "4gb" }
variable "disk" { default = "20gb" }

resource "local_file" "userdata" {
    filename = "userdata.cfg"
    content = templatefile("${path.module}/userdata.tpl", {
        ssh_authorized_key = data.digitalocean_ssh_key.default.public_key
        tailscale_key = var.ts_token
    })
}

provider "digitalocean" {
    token = var.do_token
}

data "digitalocean_ssh_key" "default" {
  name = var.do_ssh_key_name
}

data "digitalocean_volume" "vol" {
  name   = "prod-slab-vol"
  region = var.region
}

resource "digitalocean_droplet" "cloudbox" {
  name       = "cloudbox"
  size       = "s-${var.cpus}vcpu-${var.memory}"
  image      = "ubuntu-20-04-x64"
  tags       = [ "dev" ]
  region     = var.region
  monitoring = true
  ipv6       = false
  volume_ids = [data.digitalocean_volume.vol.id]
  ssh_keys   = [data.digitalocean_ssh_key.default.id]
  user_data  = local_file.userdata.content
}

resource "multipass_instance" "localbox" {
    count = 1
    name  = "localbox"
    image = "focal"
    cpus  = var.cpus
    memory = var.memory
    disk = var.disk
    cloudinit_file = local_file.userdata.filename
}
