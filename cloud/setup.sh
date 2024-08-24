#!/bin/bash

docker pull --platform linux/amd64 hashicorp/tfc-agent:latest

# Run TFC agent via Docker
docker run --name tfc-agent \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e TFC_AGENT_TOKEN -d hashicorp/tfc-agent:latest

sleep 3
echo docker ps | grep tfc-agent
echo "TFC agent is running in Docker container"
