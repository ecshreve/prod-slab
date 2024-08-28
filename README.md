# prod-slab

Compose files for deploying applications in my homelab.

## Summary

This repository contains the configuration and deployment setup for a cloud infrastructure using Terraform, Ansible, and various platforms and services like DigitalOcean, Multipass,Tailscale, Consul, Nomad, and Docker.

---

## Table of Contents

- [Core Tools](#core-tools)
- [Terraform Configuration](#terraform-configuration)
- [User Data Templates](#user-data-templates)
- [Ansible Roles and Tasks](#ansible-roles-and-tasks)
- [Environment Variables](#environment-variables)
- [Docker](#docker)
- [Usage](#usage)

## Core Tools

- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Multipass](https://multipass.run/)
- [DigitalOcean](https://www.digitalocean.com/)
- [Tailscale](https://tailscale.com/)


## Terraform Configuration

The Terraform configuration is divided into two main parts:

1. **Main Configuration (`terraform/devsync/main.tf`):**
    - Sets up the Terraform project, required providers, and variables.
    - Provisions DigitalOcean droplets and Multipass instances.
    - Goal is to create a VM on Multipass locally and a matching one in DigitalOcean

### User Data Templates

Cloud-init configurations are defined in `userdata.tpl` files for setting up a user, installing tailscale, and connecting to the tailnet on the provisioned instances.

## Ansible Roles and Tasks

Ansible is used to configure the provisioned instances. The roles include:

1. **General Setup (`ansible/roles/general`):**
    - Installs general packages.
    - Creates appdata directory in user home to persist application data.
    - Modifies sysctl entry for `net.ipv4.ip_nonlocal_bind` allowing the process to bind to an IP address that is not local or not yet assigned to the host.
    - Modifies sysctl entry for `net.ipv4.conf.all.forwarding` to enable IP forwarding, allowing the host to route packets between different networks.
    
2. **Docker Setup (`ansible/roles/docker`):**
    - Ensures Docker is installed and configured.

3. **HashiCorp Setup (`ansible/roles/hashicorp`):**
    - Installs dependencies and adds HashiCorp's apt repository.

4. **Consul Setup (`ansible/roles/consul`):**
    - Installs and configures Consul, including service files and handlers.

5. **Nomad Setup (`ansible/roles/nomad`):**
    - Installs and configures Nomad, including service files and handlers.

6. **Droplet Tasks (`ansible/roles/droplet`):**
    - Ensures directories exist, mounts volumes, and configures fstab for persistence.

## Environment Variables

Terraform uses the following environment variables:

- `TF_VAR_do_token`: DigitalOcean API token
- `TF_VAR_ts_token`: Tailscale API token
- `TF_VAR_ssh_pub_key`: Public SSH key for the created user

---
# These apps are being replaced by nomad jobs, but the general idea still applies.
### _Apps_
- [Homepage](#homepage): Dashboard
- [Homebox](#homebox): Track the things
- [Gitea](#gitea): Git the things
- [Coder](#coder): Dev the things
  
### _Monitoring_
- [cAdvisor](#monitoring-and-metrics): Container metrics
- [NodeExporter](#monitoring-and-metrics): Host metrics
- [Grafana](#monitoring-and-metrics): Visualization
- [Prometheus](#monitoring-and-metrics): Metrics collection
- [Loki](#logging): Log collection

### _Infra_
- [Tailscale](#tailscale): Network connections
- [Traefik](#traefik): Request routing

## Apps

### Homepage

[Homepage](https://github.com/gethomepage/homepage) dashboards services and bookmarks with static YAML files and Docker labels.

![Homepage Screenshot](./images/slab%20homepage.jpeg)

### Homebox

[Homebox](https://github.com/sysadminsmedia/homebox) manages inventory. Using a forked image [`ecshreve/homebox-dev`](https://github.com/ecshreve/homebox-dev) with UI tweaks.

![Homebox Screenshot](./images/homebox.jpeg)

### Gitea

[Gitea](https://gitea.io/en-us/) backs up GitHub repos and experiments with git hooks. Uses a MySQL database accessible via Adminer.

![Gitea Screenshot](./images/gitea.jpeg)

### Coder

[Coder](https://coder.com/) manages dev environments with templates and workspaces. Currently running in a bespoke and slightly brittle local setup. The application isn't really designed for a single developer use case, but I've found it much more fun than VSCode devcontainers or GitHub codespaces

![Coder Screenshot](./images/coder.jpeg)

## Observability

### Monitoring and Metrics

[cAdvisor](https://github.com/google/cadvisor) and [Node Exporter](https://github.com/prometheus/node_exporter) collect metrics.

[Grafana](https://grafana.com/) visualizes via [Prometheus](https://prometheus.io/).

#### Dashboards

- [Node Exporter Full](https://grafana.com/grafana/dashboards/1860)

![Grafana Screenshot](./images/docker%20host.jpeg)

- [cAdvisor](https://grafana.com/grafana/dashboards/19792)

![Grafana Screenshot 2](./images/container%20metrics.png)

### Logging

Network logs sent to Synology log server.

Docker container logs are collected via [Loki]() and [Promtail](), and visualized in Grafana.

A fragment like this one could be used to directly use the loki logging driver in service defs

```yaml
x-logging-loki: &loki-logging
  driver: loki
  options:
    loki-url: "http://loki:3100/loki/api/v1/push"
```

## Network

### Traefik

[Traefik](https://doc.traefik.io/traefik/routing/providers/docker/) routes requests using `CONTAINER_NAME.ecs.lan`.

### DNS

Router uses wildcard DNS A record for `*.ecs.lan` pointing to the Traefik container's local network IP, which is advertised as a subnet route in tailscale.

### Tailscale

[Tailscale](https://tailscale.com/use-cases/homelab) secures connections between hosts and containers.

## Note

This setup is in progress and **not** suitable for internet exposure without additional configuration.

## TODO

- [ ] Add raycast snippets for the coder start/stop scripts
- [ ] Terraform a DO droplet to use as a host or workspace target
- [ ] Add Kavita e-reader app
- [ ] Migrate secrets to HashiCorp Vault
- [-] Add Jaeger for tracing
- [ ] Add backup Synology host to tailnet
- [ ] Backup volumes to vault2 (rename needed)
- [ ] Implement metric snapshot emails
- [ ] Backup strategy for GitHub -> Gitea
- [ ] Check on open Coder deployment issue on macOS
- [ ] Coder server via Docker on remote host, workspaces on laptop's Docker daemon
- [ ] Configure workspaces to connect to tailnet
- [ ] Bake dotfiles into Coder image
- [ ] Automation: auto commit-push if idle
- [ ] Move Coder templates into this repo
- [x] Include Pihole in repo
- [x] Set up secondary backup Pihole (deprecated primary)
- [x] Resolve CNAME issue (moved DNS handling to Synology)
- [x] Fix Tailscale-state volume issue on down/up
