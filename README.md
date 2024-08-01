# prod-slab

This repo contains compose files for deploying applications in my homelab.

## Summary

I'm moving soon and wanted to make sure I had all my ducks in a row for setting up my homelab in the new place. Also was looking for an opportunity to play around with some configuration ideas I've had for some new tools and docker apps that have been scattered across my laptop.

---

#### _apps_
- [homebox](#homebox)
- [gitea](#gitea)
- [whoami](#whoami)
  
#### _monitoring_
- [cadvisor](#monitoring-and-metrics)
- [grafana](#monitoring-and-metrics)
- [prometheus](#monitoring-and-metrics)
- redis

#### _routing_
- [tailscale](#tailscale)
- [traefik](#traefik)


## Apps

### Homebox

[Homebox](https://github.com/sysadminsmedia/homebox) is a lightweight self-hosted inventory management type application. I'm using it to keep track of the stuff I'm moving. The image I'm using [`ecshreve/homebox-dev`](https://github.com/ecshreve/homebox-dev) is a fork of a fork of the original project with some tiny changes for my use case.

This is the main app I've been experimenting with, and part of the reason for sprucing up the lab was to make a persistent home for this data.

### Gitea

[Gitea](https://gitea.io/en-us/) is a self-hosted git service. I'm using it as a backup mechanism for some of my GitHub repos. Also played around with some git hooks and templating to automatically push to this server when I push to GitHub.

### Whoami

A simple container that returns the IP address of the host it's running on. Useful for testing routing and load balancing.

## Observability

### Monitoring and Metrics

[Grafana](https://grafana.com/) is used for visualizing metrics from various services. It is connected to a [Prometheus](https://prometheus.io/) instance that scrapes metrics from hosts and services.

[cAdvisor](https://github.com/google/cadvisor) and [Node Exporter](https://github.com/prometheus/node_exporter) are used to collect metrics from docker containers and hosts, respectively.

<!-- TODO ### Jaeger -->

### Logs

Router, firewall, and miscellaneous network logs are sent to the Synology log server.

<!-- TODO application logs -->

## Network

### Traefik

[Traefik](https://doc.traefik.io/traefik/routing/providers/docker/) handles routing requests to appropriate service by domain name. By default it creates a routing rule for each new docker service like `<CONTAINER_NAME>.ecs.lan`, creates a traefik service targeting the exposed port of the container, and listens for HTTP requests on port 80.

### DNS

I use [Pi-hole](https://pi-hole.net/) as a local DNS server. It is configured with CNAME records for each service to point to `traefik.ecs.lan`, which in turn has an A record pointing to the IP of the Tailscale sidecar service.

### Tailscale

[Tailscale](https://tailscale.com/use-cases/homelab) is installed on various hosts and containers, providing a secure connection between them. Tailscale is configured to override the connected hosts' local DNS settings, forwarding DNS requests for the `*.ecs.lan` domain to the PiHole, and all other requests to the Tailscale DNS servers, and finally to Cloudflare's DNS servers.

Requests from hosts _not_ on the Tailnet just go to Cloudflare (`1.1.1.1`).

## Note

This is a work in progress and is **not** suitable to be exposed to the internet without some hefty network configuration beyond the scope of this repo.

In my setup I have all of this sitting behind a firewall, my router does not forward any ports, VLANs are set up to separate traffic from hosts in the lab and the rest of my home network, and the docker host only listens on its Tailscale address. There's also logging and alerting in place for unusual network activity, new device connections, etc.

## TODO

- [ ] Add Jaeger back in for tracing
- [ ] Something wonky happening with the tailscale-state volume on down/up, does it need to be persistent? should it just be an ephemeral docker container / tailscale host?
- [ ] Add backup synology host to tailnet
- [ ] Backup volumes to vault2
- [ ] Spin up second backup pihole somewhere? 
- [ ] Why can't I set up CNAMEs on the ubiquiti controller?
- [ ] A daily metric snapshot email would be nice