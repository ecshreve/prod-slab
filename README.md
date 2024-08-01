# prod-slab

This repo contains compose files for deploying applications in my homelab.

## Summary

I'm moving soon and want to make sure my computer setup was in a good place before unplugging everything and installing at the new place. This also gave me a chance to play around with with configurations for [Homebox](#homebox), [Coder](#coder), and [Traefik](#traefik).

---

### _Apps_
- [Homebox](#homebox): Track my stuff
- [Gitea](#gitea): Track my code
- [Coder](#coder): Track my projects
- [Whoami](#whoami): Debug routing
  
### _Monitoring_
- [cAdvisor](#monitoring-and-metrics): Gather container metrics
- [Grafana](#monitoring-and-metrics): Visualize metrics
- [Prometheus](#monitoring-and-metrics): Collect metrics
- Redis

### _Routing_
- [Tailscale](#tailscale): Connect everything
- [Traefik](#traefik): Route requests between all the things

## Apps

### Homebox

[Homebox](https://github.com/sysadminsmedia/homebox) is a lightweight self-hosted inventory management app. I use it to keep track of the stuff I'm moving. Using the forked image [`ecshreve/homebox-dev`](https://github.com/ecshreve/homebox-dev).

### Gitea

[Gitea](https://gitea.io/en-us/) is a self-hosted Git service. I use it to back up my GitHub repos and experiment with git hooks and automatic pushes.

### Coder

[Coder](https://coder.com/) is how I manage my development projects. It provides a clean interface to build templates and workspaces. This runs locally on my laptop for now but may move to the NAS.

### Whoami

A simple container that returns the host's IP address. Useful for testing routing and load balancing. It lives alone in the main compose file for now.

## Observability

### Monitoring and Metrics

[Grafana](https://grafana.com/) visualizes metrics, connected to a [Prometheus](https://prometheus.io/) instance that scrapes metrics from hosts and services.

[cAdvisor](https://github.com/google/cadvisor) and [Node Exporter](https://github.com/prometheus/node_exporter) collect metrics from Docker containers and hosts, respectively.

### Logs

Network logs (router, firewall, etc.) are sent to the Synology log server.

## Network

### Traefik

[Traefik](https://doc.traefik.io/traefik/routing/providers/docker/) routes requests by domain name. It creates routing rules for new Docker services using `<CONTAINER_NAME>.ecs.lan`.

### DNS

I use [Pi-hole](https://pi-hole.net/) as a local DNS server. It's configured with CNAME records for services pointing to `traefik.ecs.lan`, which has an A record pointing to the Tailscale sidecar service.

### Tailscale

[Tailscale](https://tailscale.com/use-cases/homelab) provides secure connections between hosts and containers. DNS requests for `*.ecs.lan` go to Pi-hole, while other requests go to Tailscale DNS and then Cloudflare.

## Note

This setup is a work in progress and is **not** suitable for internet exposure without additional network configuration. My setup includes a firewall, no port forwarding on the router, VLANs to separate lab and home network traffic, and the Docker host listening only on its Tailscale address. Logging and alerting is set up on my router for unusual network activity.

## TODO

- [ ] Add Jaeger back in for tracing
- [ ] Include pihole in this repo?
- [ ] Fix the tailscale-state volume issue on down/up
- [ ] Add backup Synology host to tailnet
- [ ] Backup volumes to vault2(pick a new hostname for it too)
- [ ] Set up a secondary backup pihole
- [ ] Resolve CNAME setup issue on Ubiquiti controller
- [ ] Implement metric snapshot emails
- [ ] Plan a backup strategy for GitHub -> Gitea
- [ ] Check on open issue deploying coder via doker on macs
- [ ] Deploy just the server component via docker on the NAS and have the target docker host for coder workspaces be the docker daemon on my laptop
- [ ] Configure workspaces to connect to the tailnet directly
- [ ] Bake dotfiles into the coder image
- [ ] Look into automation, auto commit-push if idle with changes for x minutes
- [ ] move coder templates into this repo
