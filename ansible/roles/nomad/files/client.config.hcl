datacenter = "dc1"
data_dir   = "/opt/nomad/data"

ui {
  enabled = true
}

client {
  enabled = true
  network_interface = "tailscale0"
  options {
    docker.privileged.enabled = true
    docker.volumes.enabled = true
  }
  host_network "tailscale" {
    cidr = "100.0.0.0/8"
  }
  host_volume "appdata" {
    path = "/home/eric/appdata"
    read_only = false
  }
}

advertise {
  http = "{{ GetInterfaceIP \"tailscale0\" }}:4646"
  rpc = "{{ GetInterfaceIP \"tailscale0\" }}:4647"
  serf = "{{ GetInterfaceIP \"tailscale0\" }}:4648"
}

consul {
  address = "{{ GetInterfaceIP \"tailscale0\" }}:8500"
  client_service_name = "nomad-client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}

plugin "docker" {
  config {
    pull_activity_timeout = "5m",
    allow_privileged      = true
    extra_labels = ["job_name", "task_group_name", "task_name", "namespace", "node_name"]
    allow_caps = [
      "audit_write",
      "chown",
      "dac_override",
      "fowner",
      "fsetid",
      "kill",
      "mknod",
      "net_bind_service",
      "setfcap",
      "setgid",
      "setpcap",
      "setuid",
      "sys_chroot",
      "net_raw",
      "net_admin",
      "net_broadcast",
    ]

    volumes {
      enabled = true
    }
  }
}

telemetry {
  collection_interval        = "10s"
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}