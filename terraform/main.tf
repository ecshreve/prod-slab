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
    hcp = {
      source = "hashicorp/hcp"
      version = "0.95.0"
    }
  }
}

provider "hcp" {}

data "hcp_vault_secrets_app" "prod" {
  app_name = "prod-slab"
}

provider "digitalocean" {
    token = data.hcp_vault_secrets_app.prod.secrets["do_tok"]
}

resource "digitalocean_ssh_key" "default" {
  name       = "do ssh key"
  public_key = data.hcp_vault_secrets_app.prod.secrets["ssh_pub"]
}

data "digitalocean_volume" "vol" {
  name   = "prod-slab-vol"
  region = "sfo3"
}

resource "local_sensitive_file" "userdata" {
  content = templatefile("${path.module}/userdata.tpl", {
    ssh_authorized_key = data.hcp_vault_secrets_app.prod.secrets["ssh_pub"]
    tailscale_key = data.hcp_vault_secrets_app.prod.secrets["ts_tok"]
  })
  
  filename = "${path.module}/userdata.cfg"
}

resource "digitalocean_droplet" "server" {
  count      = 1
  name       = "cloudbox${count.index}"
  size       = "s-2vcpu-4gb"
  image      = "ubuntu-20-04-x64"
  tags       = [ "dev" ]
  region     = "sfo3"
  monitoring = true
  ipv6       = true
  volume_ids = [data.digitalocean_volume.vol.id]
  ssh_keys   = [digitalocean_ssh_key.default.fingerprint]
  user_data  = file(local_sensitive_file.userdata.filename)
}

output "do_public_ip" {
  value = digitalocean_droplet.server.*.ipv4_address
}

output "do_private_ip" {
  value = digitalocean_droplet.server.*.ipv4_address_private 
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

