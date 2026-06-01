#!/bin/bash
set -e
TARGET=$1
NGINX_CONF="$HOME/bluegreen-cicd/nginx/nginx.conf"

if [ "$TARGET" = "blue" ]; then PORT=8080
elif [ "$TARGET" = "green" ]; then PORT=8081
else echo "Usage: $0 blue|green"; exit 1; fi

echo ">>> Switching to $TARGET (port $PORT)..."
sed -i "s|server host.docker.internal:[0-9]*;|server host.docker.internal:$PORT;|g" $NGINX_CONF
docker exec nginx-proxy nginx -s reload
sleep 2
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)
if [ "$HTTP" = "200" ]; then
  echo ">>> Smoke test PASSED — $TARGET is live"
  exit 0
else
  echo ">>> Smoke test FAILED (HTTP $HTTP)"
  exit 1
fi
