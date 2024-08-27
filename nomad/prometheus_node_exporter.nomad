job "prometheus_node_exporter" {
  datacenters = ["dc1"]
  type        = "system"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "prometheus_node_exporter" {

    network {
      port "exporter" {
        to = 9100
        static = 9100
      }
    }

    task "prometheus_node_exporter" {
      driver = "docker"

      config {
        image    = "prom/node-exporter"
        args     = ["--path.rootfs=/host"]
        ports    = ["exporter"]
        pid_mode = "host"

        volumes = [
          "/:/host:ro,rslave",
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "prometheus-node-exporter"
        port = "exporter"
      }
    }
  }
}
