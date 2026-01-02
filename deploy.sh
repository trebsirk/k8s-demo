#!/usr/bin/env bash
set -euo pipefail

set -a      # auto-export all variables
source .env
set +a      # stop auto-export

./scripts/validate-env.sh

: "${APP_NAME:?APP_NAME not set}"
: "${IMAGE_NAME:?IMAGE_NAME not set}"
: "${APP_VERSION:?APP_VERSION not set}"
: "${REPLICAS:?REPLICAS not set}"
: "${CONTAINER_PORT:?CONTAINER_PORT not set}"
: "${SERVICE_PORT:?SERVICE_PORT not set}"

echo "▶ Deploying ${APP_NAME}:${APP_VERSION}"
# eval $(minikube docker-env)
# To avoid accidentally replacing unintended variables:
envsubst '$APP_NAME $APP_VERSION $IMAGE_NAME $REPLICAS $CONTAINER_PORT' \
 < k8s/deployment.yaml | kubectl apply -f -
envsubst '$APP_NAME $SERVICE_PORT $CONTAINER_PORT' \
 < k8s/service.yaml    | kubectl apply -f -

kubectl rollout status deployment/${APP_NAME}

echo "✅ Deployment successful"
