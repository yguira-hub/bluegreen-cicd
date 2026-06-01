#!/bin/bash
set -e
NGINX_CONF="$HOME/bluegreen-cicd/nginx/nginx.conf"
CURRENT=$(grep -oP 'server host\.docker\.internal:\K[0-9]+' $NGINX_CONF)
if [ "$CURRENT" = "8081" ]; then ROLLBACK=8080; ENV=blue
else ROLLBACK=8081; ENV=green; fi
echo ">>> ROLLBACK to $ENV..."
sed -i "s|server host.docker.internal:[0-9]*;|server host.docker.internal:$ROLLBACK;|g" $NGINX_CONF
docker exec nginx-proxy nginx -s reload
echo ">>> Rollback done. Active: $ENV"
