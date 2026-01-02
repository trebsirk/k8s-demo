#!/usr/bin/env bash
set -euo pipefail

echo "▶ Starting Minikube..."
minikube start --driver=docker

echo "▶ Configuring Docker to use Minikube daemon..."
eval "$(minikube docker-env)"

echo "✅ Minikube is ready"
