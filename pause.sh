#!/usr/bin/env bash
set -euo pipefail

source .env
: "${APP_NAME:?APP_NAME not set}"

kubectl scale deployment "${APP_NAME}" --replicas=0
echo "⏸ ${APP_NAME} paused"
