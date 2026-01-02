#!/usr/bin/env bash
set -euo pipefail

source .env
: "${APP_NAME:?APP_NAME not set}"
: "${REPLICAS:?REPLICAS not set}"

kubectl scale deployment "${APP_NAME}" --replicas="${REPLICAS}"
kubectl rollout status deployment "${APP_NAME}"
echo "▶ ${APP_NAME} resumed"
