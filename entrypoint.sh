#!/bin/sh
set -e

echo "Starting Nginx with PORT=${PORT}"

envsubst '${PORT} ${ACTIVE_POOL}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
