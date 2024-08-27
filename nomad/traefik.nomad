job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    constraint {
      attribute = "${node.unique.name}"
      operator  = "regexp"
      value     = "^cloudbox$"
    }

    network {
      port "http" {
        host_network = "tailscale"
        static = 80
      }
      port "api" {
        host_network = "tailscale"
        static = 8081
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v3.1"
        network_mode = "host"
        ports = [
          "api",
          "http",
        ]
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data = <<EOF
[global]
    checkNewVersion = true
    sendAnonymousUsage = false
[metrics]
    [metrics.prometheus]
        addEntryPointsLabels = true
        addRoutersLabels = true
        addServicesLabels = true
[entryPoints]
    [entryPoints.http]
        address = ":80"
        asDefault = true
    [entryPoints.http.forwardedHeaders]
        insecure = true
    [entryPoints.http.proxyProtocol]
        insecure = true
    [entryPoints.traefik]
        address = ":8081"
[log]
    level = "debug"
[api]
    dashboard = true
    insecure = true
[ping]
    entryPoint = "traefik"
[providers.consulcatalog]
    prefix           = "traefik"
    exposedByDefault = false
    defaultRule = "Host(`{{ .Name }}.ecs.lan`)"

    [providers.consulcatalog.endpoint]
      address = "{{{ sockaddr "GetInterfaceIP \"tailscale0\"" }}}:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
        env         = false
        change_mode = "noop"
        left_delimiter = "{{{"
        right_delimiter = "}}}"
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        name = "traefik-http"
        port = "http"
        check {
          type     = "tcp"
          interval = "3s"
          timeout  = "1s"
        }
      }
      service {
        name = "traefik-api"
        port = "api"
        check {
          type     = "tcp"
          interval = "3s"
          timeout  = "1s"
        }
      }
    }
  }
}