job "grafana" {
  datacenters = ["dc1"]
  type        = "service"

  group "grafana" {
    count = 1

    network {
        port "grafana" {
            to = 3000
        }
    }

    task "grafana" {
      driver = "docker"

      env = {
        GF_SECURITY_ALLOW_EMBEDDING = "true"
      }

      config {
        image = "grafana/grafana-enterprise"
        ports = ["grafana"]
        volumes = [
          ":/etc/grafana/grafana.ini",
        ]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "grafana"
        port = "grafana"
        tags = ["traefik.enable=true"]
      }
    }
  }
}