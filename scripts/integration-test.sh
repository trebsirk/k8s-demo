#!/usr/bin/env bash
set -euo pipefail

source scripts/lib.sh
load_env
require_env APP_NAME SERVICE_PORT INTEGRATION_LOCAL_PORT

echo "🧪 Running integration tests..."

wait_for_deployment "${APP_NAME}"

port_forward_bounded "${APP_NAME}" "${INTEGRATION_LOCAL_PORT}" "${SERVICE_PORT}"
wait_for_http "http://localhost:${INTEGRATION_LOCAL_PORT}/health"

export BASE_URL="http://localhost:${INTEGRATION_LOCAL_PORT}"

pytest tests/
