#!/usr/bin/env bash
set -euo pipefail

source .env

: "${APP_NAME:?APP_NAME not set}"

echo "▶ Stopping ${APP_NAME}"

kubectl delete service "${APP_NAME}" --ignore-not-found
kubectl delete deployment "${APP_NAME}" --ignore-not-found

echo "✅ ${APP_NAME} stopped"
