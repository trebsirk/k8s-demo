#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Resetting application..."

./stop.sh || true
./build.sh
./deploy.sh

echo "✅ Reset complete"
