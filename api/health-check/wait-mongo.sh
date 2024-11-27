#!/usr/bin/env bash
# Use this script to test if a given TCP host/port are available

set -e

TIMEOUT=15
QUIET=0

usage() {
  echo "Usage: $0 host:port [-s] [-t timeout] [-- command args]"
  echo "  -h MONGO_HOST    Host or IP under test"
  echo "  -p MONGO_PORT    TCP port under test"
  echo "  -s         Only execute command if the test succeeds"
  echo "  -q         Suppress status messages"
  echo "  -t TIMEOUT Timeout in seconds, zero for no timeout"
  echo "  -- COMMAND ARGS  Execute command with args after the test finishes"
  exit 1
}

log() {
  if [[ $QUIET -ne 1 ]]; then echo "$@" >&2; fi
}

wait_for() {
  if [[ $TIMEOUT -gt 0 ]]; then
    log "Waiting for $MONGO_HOST:$MONGO_PORT (with a $TIMEOUT second timeout)..."
  else
    log "Waiting for $MONGO_HOST:$MONGO_PORT without a timeout..."
  fi

  SECONDS=0
  while ! nc -z "$MONGO_HOST" "$MONGO_PORT"; do
    sleep 1
    if [[ $TIMEOUT -gt 0 && $SECONDS -ge $TIMEOUT ]]; then
      log "Timed out after $TIMEOUT seconds waiting for $MONGO_HOST:$MONGO_PORT"
      return 1
    fi
  done
}

wait_for_and_execute() {
  wait_for
  RESULT=$?
  if [[ $RESULT -eq 0 ]]; then
    if [[ $QUIET -ne 1 ]]; then log "$MONGO_HOST:$MONGO_PORT is available $RESULT"; fi
    if [[ $# -gt 0 ]]; then exec "$@"; fi
  fi
  return $RESULT
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    *:* )
      MONGO_HOST_PORT=(${1//:/ })
      MONGO_HOST=${MONGO_HOST_PORT[0]}
      MONGO_PORT=${MONGO_HOST_PORT[1]}
      shift 1
      ;;
    -h)
      MONGO_HOST="$2"
      shift 2
      ;;
    -p)
      MONGO_PORT="$2"
      shift 2
      ;;
    -q)
      QUIET=1
      shift 1
      ;;
    -s)
      STRICT=1
      shift 1
      ;;
    -t)
      TIMEOUT="$2"
      shift 2
      ;;
    --)
      shift
      CMD=("$@")
      break
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$MONGO_HOST" || -z "$MONGO_PORT" ]]; then
  echo "Error: you need to provide a host and port to test."
  usage
fi

wait_for_and_execute "${CMD[@]}"
