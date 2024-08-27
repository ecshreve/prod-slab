job "docker-registry" {
  datacenters = ["dc1"]
  type        = "service" # This is a service job

  group "registry" {
    network {
      port "registry" {
        to = 5000
        static = 5000
      }
    }

    task "registry" {
      driver = "docker"

      config {
        image = "registry:2"
        ports = ["registry"]
        volumes = [
          "/home/eric/appdata/registry:/var/lib/registry"
        ]
      }

      env {
        REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/var/lib/registry"
      }

      resources {
        cpu    = 500
        memory = 256
      }

      restart {
        attempts = 2
        interval = "30m"
        delay    = "15s"
        mode     = "delay"
      }

      service {
        name = "registry"
        port = "registry"
        tags = ["traefik.enable=true"]
    }
  }
  }
}