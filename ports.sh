#! /bin/bash

# Save this script in one of your shares and schedule it to run as root at boot
#   through Control Panel -> Task Scheduler
# DSM upgrades will reset these changes, which is why we schedule them to happen automatically

# NGINX Ports - CUSTOMIZE THIS
# Several Synology services use port 80 and 443 via Nginx. This conflicts with Traefik, Nginx Proxy Manager, Caddy, etc. 
# This script reconfigures Nginx to use non-default ports, leaving ports 80 and 443 free for reverse proxy.

DEFAULT_HTTP_PORT=80 # typically left as-is, 80.
DEFAULT_HTTPS_PORT=443 # typically left as-is, 443.
NEW_HTTP_PORT=81
NEW_HTTPS_PORT=444

################ DO NOT EDIT BEYOND THIS LINE ###########################
sed -i "s/^\([ \t]\+listen[ \t]\+[]:[]*\)$DEFAULT_HTTP_PORT\([^0-9]\)/\1$NEW_HTTP_PORT\2/" /usr/syno/share/nginx/*.mustache
sed -i "s/^\([ \t]\+listen[ \t]\+[]:[]*\)$DEFAULT_HTTPS_PORT\([^0-9]\)/\1$NEW_HTTPS_PORT\2/" /usr/syno/share/nginx/*.mustache

sudo synosystemctl restart nginx