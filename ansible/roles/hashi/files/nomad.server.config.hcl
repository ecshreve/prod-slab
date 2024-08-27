datacenter = "dc1"
data_dir   = "/opt/nomad/data"

server {
  enabled = true
  bootstrap_expect = 1
}

ui {
  enabled = true
}