#!/usr/bin/env bash
set -euo pipefail

# set -a      # auto-export all variables
# source .env
# set +a      # stop auto-export

source scripts/lib.sh
load_env
require_env APP_NAME APP_VERSION IMAGE_NAME CONTAINER_PORT SERVICE_PORT

# REQUIRED_VARS=(
#   APP_NAME
#   APP_VERSION
#   IMAGE_NAME
#   CONTAINER_PORT
#   SERVICE_PORT
# )

# echo "🔍 Validating environment variables..."

# for var in "${REQUIRED_VARS[@]}"; do
#   if [[ -z "${!var:-}" ]]; then
#     echo "❌ ERROR: Required env var '$var' is not set or empty"
#     exit 1
#   fi
# done

# echo "✅ All required env vars are set"


echo "🔎 Checking for unsubstituted variables in rendered manifests..."

for file in k8s/*.yaml; do
  rendered=$(envsubst < "$file")

  if echo "$rendered" | grep -q '\${'; then
    echo "❌ ERROR: Unsubstituted variables found in $file"
    echo "Rendered output:"
    echo "-----------------"
    echo "$rendered"
    exit 1
  fi
done

echo "✅ All manifests fully rendered"
