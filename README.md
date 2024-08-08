# prod-slab

This repo contains compose files for deploying applications in my homelab.

## Summary

I'm moving soon and want to make sure my computer setup was in a good place before unplugging everything and installing at the new place. This also gave me a chance to play around with with configurations for [Homebox](#homebox), [Coder](#coder), and [Traefik](#traefik).

---

### _Apps_
- [Homepage](#homepage): Dashboard of all the things
- [Homebox](#homebox): Track stuff
- [Gitea](#gitea): Track code
- [Coder](#coder): Track dev projects
  
### _Monitoring_
- [cAdvisor](#monitoring-and-metrics): Gather container metrics
- [Grafana](#monitoring-and-metrics): Visualize metrics
- [Prometheus](#monitoring-and-metrics): Collect metrics

### _Routing_
- [Tailscale](#tailscale): Connect everything
- [Traefik](#traefik): Route requests between all the things

## Apps

### Homepage

[Homepage](https://github.com/gethomepage/homepage) is a dashboard for all the things. I use it to keep track of my services and their status. It also has some bookmarks and widgets for easy access. The configuration is a combinationo of static yaml files and automated discovery via docker labels.

![homepage-screenshot](./images/slab%20homepage.jpeg)

### Homebox

[Homebox](https://github.com/sysadminsmedia/homebox) is a lightweight self-hosted inventory management app. I started using it to keep track of stuff while I'm moving. Currently running a forked image [`ecshreve/homebox-dev`](https://github.com/ecshreve/homebox-dev) with some tiny tweaks to the UI fixing some cosmetic annoyances.

![homebox-screenshot](./images/homebox.jpeg)

### Gitea

[Gitea](https://gitea.io/en-us/) is a self-hosted Git service. I use it to back up my GitHub repos and experiment with git hooks, templates, etc. This app is backed by a mysql database in another container, accessible directly for troubleshooting via adminer.

![gitea-screenshot](./images/gitea.jpeg)

### Coder

[Coder](https://coder.com/) is how I manage my development environments. It provides a clean interface to build templates and workspaces. This runs locally on my laptop for now but may move to the NAS.

![coder-screenshot](./images/coder.jpeg)


## Observability

### Monitoring and Metrics

[cAdvisor](https://github.com/google/cadvisor) and [Node Exporter](https://github.com/prometheus/node_exporter) collect metrics from Docker containers and hosts, respectively.

[Grafana](https://grafana.com/) visualizes metrics, connected to a [Prometheus](https://prometheus.io/) instance that scrapes from various hosts and services.

#### Dashboards

[Node Exporter Full](https://grafana.com/grafana/dashboards/1860)

![grafana-screenshot](./images/docker%20host.jpeg)

[cAdvisor](https://grafana.com/grafana/dashboards/19792) (slightly modified)

![grafana-screenshot2](./images/container%20metrics.png)

### Logs

Network logs (router, firewall, etc.) are sent to the Synology log server.

## Network

### Traefik

[Traefik](https://doc.traefik.io/traefik/routing/providers/docker/) routes requests by domain name. It creates routing rules for new Docker services using `<CONTAINER_NAME>.ecs.lan`.

### DNS

I use the DNS Server package on a Synology NAS as a local DNS server. It's configured with CNAME records for services pointing to `traefik.ecs.lan`, which has an A record pointing to the Tailscale sidecar container.

### Tailscale

[Tailscale](https://tailscale.com/use-cases/homelab) provides secure connections between hosts and containers. DNS requests for `*.ecs.lan` go to a local DNS server running on the Synology NAS via a split tunnel configured in the admin console. Other traffic is handled as usual, with non-tailscale traffic using Cloudflare's public DNS.

## Note

This setup is a work in progress and is **not** suitable for internet exposure without additional network configuration. My setup includes a firewall, no port forwarding on the router, VLANs to separate lab and home network traffic, and the Docker host listening only on its Tailscale address. Logging and alerting is set up on my router for unusual network activity.

## TODO

- [ ] Add kavita e-reader app
- [ ] migrate to handling secrets with hashicorp vault.
- [ ] Add Jaeger back in for tracing
- [ ] Add backup Synology host to tailnet
- [ ] Backup volumes to vault2(pick a new hostname for it too)
- [ ] Implement metric snapshot emails
- [ ] Plan a backup strategy for GitHub -> Gitea
- [ ] Check on open issue deploying coder via doker on macs
- [ ] Deploy just the server component via docker on the NAS and have the target docker host for coder workspaces be the docker daemon on my laptop
- [ ] Configure workspaces to connect to the tailnet directly
- [ ] Bake dotfiles into the coder image
- [ ] Look into automation, auto commit-push if idle with changes for x minutes
- [ ] move coder templates into this repo
- [x] Include pihole in this repo?
- [x] Set up a secondary backup pihole
    - deprecated the pihole entirely
- [x] Resolve CNAME setup issue on Ubiquiti controller
    - moved DNS handling to the synology dns server
- [x] Fix the tailscale-state volume issue on down/up


