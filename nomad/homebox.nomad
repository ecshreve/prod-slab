job "homebox" {
  datacenters = ["dc1"]

  group "homebox" {
    count = 1

    constraint {
      attribute = "${node.unique.name}"
      operator  = "regexp"
      value     = "^localbox$"
    }

    network {
      port "homebox" {
        static = 7745
      }
    }

    task "homebox" {
      driver = "docker"

      config {
        image = "registry.ecs.lan:5000/homebox-dev:latest"
        ports = ["homebox"]
        volumes = [
          "/home/eric/appdata/homebox/data:/data"
        ]
      }

      env {
        TZ = "America/Los_Angeles"
      }

      resources {
        cpu    = 500
        memory = 256
      }

      service {
        name = "homebox"
        port = "homebox"
        tags = ["traefik.enable=true"]
    }
  }
  }
}