#!/bin/bash
set -e
NGINX_DIR="$HOME/bluegreen-cicd/nginx"

CURRENT=$(grep -o 'host.docker.internal:[0-9]*' $NGINX_DIR/nginx.conf | grep -o '[0-9]*$')
if [ "$CURRENT" = "8081" ]; then
    ROLLBACK=blue
else
    ROLLBACK=green
fi

echo ">>> ROLLBACK to $ROLLBACK..."
cp $NGINX_DIR/${ROLLBACK}.conf $NGINX_DIR/nginx.conf
docker exec nginx-proxy nginx -s reload
echo ">>> Rollback done. Active: $ROLLBACK"
