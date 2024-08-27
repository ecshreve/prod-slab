job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "prometheus" {
    count = 1

    network {
      port "prometheus" {
        to = 9090
        static = 9090
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus"
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]
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

  - job_name: "node_exporter"
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus" }}:8500'
      services:
      - "prometheus-node-exporter"
    metrics_path: "/metrics"

  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus" }}:8500'
      services: ['nomad-client', 'nomad']
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
EOF
        destination = "local/prometheus.yml"
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