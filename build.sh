#!/usr/bin/env bash
set -euo pipefail

set -a      # auto-export all variables
source .env
set +a      # stop auto-export

: "${IMAGE_NAME:?IMAGE_NAME not set}"
: "${APP_VERSION:?APP_VERSION not set}"

IMAGE="${IMAGE_NAME}:${APP_VERSION}"

eval $(minikube docker-env)

echo "▶ Building image ${IMAGE}..."
docker build -t "${IMAGE}" .

echo "✅ Image built"
