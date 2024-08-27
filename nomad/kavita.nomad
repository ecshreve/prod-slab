job "kavita" {
  datacenters = ["dc1"]
  type        = "service"

  group "kavita" {
    count = 1

    network {
        port "kavita" {
            static = 5000
        }
    }

    volume "appdata" {
      type      = "host"
      read_only = false
      source    = "appdata"
    }

    task "kavita" {
      driver = "docker"

      env {
        PUID = "1001"
        PGID = "1001"
        TZ = "America/Los_Angeles"
      }

      config {
        image = "lscr.io/linuxserver/kavita:latest"
        ports = ["kavita"]
        volumes = [
          "/home/eric/appdata/kavita/config:/config",
          "/home/eric/appdata/kavita/data:/data"
        ]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "kavita"
        port = "kavita"
        tags = ["traefik.enable=true"]
      }
    }
  }
}