datacenter = "dc1"
data_dir   = "/opt/consul"
server     = true
bootstrap_expect = 1

# hcp cloud config goes here

client_addr = "{{GetInterfaceIP \"tailscale0\"}}"
advertise_addr = "{{GetInterfaceIP \"tailscale0\"}}"
bind_addr = "{{GetInterfaceIP \"tailscale0\"}}"
advertise_addr_wan = "{{GetInterfaceIP \"tailscale0\"}}"

translate_wan_addrs = true
enable_syslog = true

ports {
  grpc  = 8502
  dns   = 8600
  http  = 8500
}

ui_config {
  enabled = true
}

connect {
  enabled = false
}

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

# Enable script checks
enable_script_checks       = true
enable_local_script_checks = true