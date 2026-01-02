#!/usr/bin/env bash
set -euo pipefail

set -a      # auto-export all variables
source .env
set +a      # stop auto-export

LOCAL_PORT=8000
BASE_URL="http://127.0.0.1:${LOCAL_PORT}"

# kubectl port-forward service/hello-k8s 8000:80 &
kubectl port-forward service/${APP_NAME} ${LOCAL_PORT}:${SERVICE_PORT} >/dev/null 2>&1 &

PF_PID=$!

# Always clean up port-forward
cleanup() {
  kill "${PF_PID}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

sleep 2
BASE_URL="${BASE_URL}" pytest tests/test_api.py

echo "✅ API tests passed"
