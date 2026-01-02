#!/usr/bin/env bash
set -euo pipefail

source scripts/lib.sh
load_env
require_env APP_NAME SERVICE_PORT CONTRACT_LOCAL_PORT APP_VERSION

echo "📜 Running contract tests..."

wait_for_deployment "${APP_NAME}"

port_forward_bounded "${APP_NAME}" "${CONTRACT_LOCAL_PORT}" "${SERVICE_PORT}"
wait_for_http "http://localhost:${CONTRACT_LOCAL_PORT}/health"

RESPONSE=$(curl -s "http://localhost:${CONTRACT_LOCAL_PORT}/health")

echo "$RESPONSE" | jq -e '.status == "ok"' >/dev/null
echo "$RESPONSE" | jq -e ".version == \"${APP_VERSION}\"" >/dev/null

echo "✅ Contract tests passed"
