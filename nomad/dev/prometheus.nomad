job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "prometheus" {
    count = 1

    network {
      port "prometheus" {
        static = 9090
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus"
        command = "--config.file=/etc/prometheus/prometheus.yml"
        ports = ["prometheus"]
      }

      template {
        data = <<EOF
# prometheus.yml
---
global:
  scrape_interval: 10s
  evaluation_interval: 10s
  scrape_timeout: 10s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
    metrics_path: /metrics
EOF
        destination = "local/etc/prometheus/prometheus.yml"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "prometheus"
        port = "prometheus"
        tags = ["traefik.enable=true"]
      }
    }
  }
}