terraform {
  cloud {
    organization = "slablan"

    workspaces {
      name = "prod-slab"
    }
  }

  required_providers {
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

resource "local_file" "userdata" {
  content = templatefile("${path.module}/userdata.tpl", {
    ssh_authorized_key = data.digitalocean_ssh_key.default.public_key
    tailscale_key = data.hcp_vault_secrets_app.prod.secrets["ts_tok"]
  })
  
  filename = "${path.module}/userdata.cfg"
}

resource "multipass_instance" "vm" {
    count = 3
    name  = "srv${count.index}"
    image = "focal"
    cpus  = 2
    memory = "2G"
    disk = "20G"
    cloudinit_file = local_file.userdata.filename
}