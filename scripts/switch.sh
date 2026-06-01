#!/bin/bash
set -e
TARGET=$1
NGINX_DIR="$HOME/bluegreen-cicd/nginx"

if [ "$TARGET" = "blue" ]; then
    cp $NGINX_DIR/blue.conf $NGINX_DIR/nginx.conf
elif [ "$TARGET" = "green" ]; then
    cp $NGINX_DIR/green.conf $NGINX_DIR/nginx.conf
else
    echo "Usage: $0 blue|green"
    exit 1
fi

echo ">>> Switching to $TARGET..."
docker exec nginx-proxy nginx -s reload
sleep 2

HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)
if [ "$HTTP" = "200" ]; then
    ACTUAL=$(curl -s http://localhost/health | grep -o '"color":"[^"]*"' | cut -d'"' -f4)
    echo ">>> Smoke test PASSED — active: $ACTUAL"
    exit 0
else
    echo ">>> Smoke test FAILED (HTTP $HTTP)"
    exit 1
fi
