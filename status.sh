#!/usr/bin/env bash
set -euo pipefail

source .env
: "${APP_NAME:?APP_NAME not set}"

echo "📦 Deployment:"
kubectl get deployment "${APP_NAME}"

echo
echo "🧱 Pods:"
kubectl get pods -l app="${APP_NAME}"

echo
echo "🌐 Service:"
kubectl get service "${APP_NAME}"

echo
echo "👤 Endpoints:"
kubectl get endpoints "${APP_NAME}"

echo
echo "모 Rollout Status:"
kubectl rollout status deployment/${APP_NAME}
