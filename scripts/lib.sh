#!/usr/bin/env bash
set -euo pipefail

#######################################
# Internal state for cleanup
#######################################
__PF_PIDS=()

#######################################
# Load and export environment variables
#######################################
load_env() {
  if [[ ! -f .env ]]; then
    echo "❌ .env file not found"
    exit 1
  fi

  set -a
  source .env
  set +a
}

#######################################
# Validate required environment variables
#######################################
require_env() {
  local missing=0

  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; then
      echo "❌ Required env var '$var' is not set"
      missing=1
    fi
  done

  [[ "$missing" -eq 0 ]] || exit 1
}

#######################################
# Register PID for cleanup
#######################################
register_cleanup_pid() {
  __PF_PIDS+=("$1")
}

#######################################
# Cleanup handler (kills all registered PIDs or process groups)
#######################################
cleanup() {
  for pid in "${__PF_PIDS[@]:-}"; do
    if [[ -n "$pid" ]]; then
      # kill the process (parent PID)
      # kill "$pid" >/dev/null 2>&1 || true

      # Kill entire process group. 
      # We must ensure cleanup kills the entire process group, 
      # not just the parent PID.
      kill -- "-$pid" >/dev/null 2>&1 || true
    fi
  done
}

trap cleanup EXIT INT TERM

#######################################
# Wait for deployment readiness
#######################################
wait_for_deployment() {
  local deployment="$1"
  echo "⏳ Waiting for deployment/${deployment} to be ready..."
  kubectl rollout status deployment "${deployment}" --timeout=60s
}

#######################################
# Start port-forward and auto-register for cleanup
#######################################
port_forward() {
  local service="$1"
  local local_port="$2"
  local service_port="$3"

  kubectl port-forward "svc/${service}" "${local_port}:${service_port}" \
    >/tmp/port-forward-${service}-${local_port}.log 2>&1 &

  local pid=$!
  register_cleanup_pid "$pid"
}

#######################################
# Start resilient port-forward
#######################################
port_forward_resilient() {
  local service="$1"
  local local_port="$2"
  local service_port="$3"
  
  (
    set -euo pipefail

    # Create a new process group
    # Background subshell becomes a process group leader
    # kill -- -$pid reliably terminates in cleanup() above:
        # supervisor
        # kubectl
        # any grandchildren
    set -m

    echo "⏳ Waiting for svc/${service} endpoints..."
    until kubectl get endpoints "${service}" \
      -o jsonpath='{.subsets[*].addresses[*].ip}' | grep -q .; do
      sleep 1
    done

    echo "🔁 Starting resilient port-forward for ${service} (${local_port}:${service_port})"

    while true; do
      kubectl port-forward "svc/${service}" \
        "${local_port}:${service_port}" \
        >/tmp/port-forward-${service}-${local_port}.log 2>&1 || true
      sleep 1
    done
  ) &

  local pid=$!
  register_cleanup_pid "$pid"
}

#######################################
# Start bounded port-forward
#######################################
port_forward_bounded() {
  local service="$1"
  local local_port="$2"
  local service_port="$3"

  echo "⏳ Waiting for svc/${service} endpoints..."
  kubectl wait \
    --for=condition=ready pod \
    -l app="${service}" \
    --timeout=60s

  kubectl port-forward "svc/${service}" \
    "${local_port}:${service_port}" \
    >/tmp/port-forward-${service}-${local_port}.log 2>&1 &

  local pid=$!
  register_cleanup_pid "$pid"
}


wait_for_http() {
  local url="$1"
  local retries=30

  for _ in $(seq 1 "$retries"); do
    if curl -sf "$url" >/dev/null; then
      return 0
    fi
    sleep 1
  done

  echo "❌ Service did not become ready: $url"
  exit 1
}
