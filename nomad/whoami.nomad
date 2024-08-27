job "whoami" {
  datacenters = ["dc1"]
  type = "system"

  group "whoami" {

    network {
       mode = "host"
       port "http" {
         to = -1
       }
    }

    service {
      name = "whoami"
      port = "http"
      provider = "consul"

      tags = [
        "traefik.enable=true",
      ]
    }

    task "whoami" {
      env {
        WHOAMI_PORT_NUMBER = "${NOMAD_PORT_http}"
      }

      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["http"]
      }
    }
  }
}

