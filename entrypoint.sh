#!/bin/sh
set -e

echo "Starting Nginx with PORT=${PORT} and ACTIVE_POOL=${ACTIVE_POOL}"

# Dynamically substitute PORT and ACTIVE_POOL into Nginx config
envsubst '${PORT} ${ACTIVE_POOL}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
