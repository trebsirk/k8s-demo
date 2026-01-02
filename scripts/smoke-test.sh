#!/usr/bin/env bash
set -euo pipefail

source scripts/lib.sh
load_env
require_env APP_NAME SERVICE_PORT SMOKE_LOCAL_PORT

echo "🔥 Running smoke test..."

wait_for_deployment "${APP_NAME}"

port_forward_bounded "${APP_NAME}" "${SMOKE_LOCAL_PORT}" "${SERVICE_PORT}"
wait_for_http "http://localhost:${SMOKE_LOCAL_PORT}/health"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  "http://localhost:${SMOKE_LOCAL_PORT}/health")

[[ "$HTTP_CODE" == "200" ]] || {
  echo "❌ Smoke test failed: HTTP ${HTTP_CODE}"
  exit 1
}

echo "✅ Smoke test passed"
