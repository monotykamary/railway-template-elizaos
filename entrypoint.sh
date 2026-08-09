#!/usr/bin/env bash
set -Eeuo pipefail

require() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf 'Required variable %s is not set.\n' "$name" >&2
    exit 1
  fi
}

for name in \
  POSTGRES_URL \
  OPENAI_API_KEY \
  BASIC_AUTH_USERNAME \
  BASIC_AUTH_PASSWORD \
  ELIZA_SERVER_AUTH_TOKEN \
  SECRET_SALT
do
  require "$name"
done

case "$BASIC_AUTH_USERNAME" in
  *[!A-Za-z0-9._-]*|'')
    printf 'BASIC_AUTH_USERNAME may contain only letters, numbers, dot, underscore, and hyphen.\n' >&2
    exit 1
    ;;
esac

case "$ELIZA_SERVER_AUTH_TOKEN" in
  *[!A-Za-z0-9_-]*|'')
    printf 'ELIZA_SERVER_AUTH_TOKEN may contain only letters, numbers, underscore, and hyphen.\n' >&2
    exit 1
    ;;
esac

if (( ${#BASIC_AUTH_PASSWORD} < 16 || ${#ELIZA_SERVER_AUTH_TOKEN} < 24 || ${#SECRET_SALT} < 24 )); then
  printf 'Basic-auth passwords require 16 characters; API tokens and secret salts require 24 characters.\n' >&2
  exit 1
fi

export BASIC_AUTH_HASH
BASIC_AUTH_HASH="$(printf '%s\n' "$BASIC_AUTH_PASSWORD" | caddy hash-password)"
unset BASIC_AUTH_PASSWORD

caddy validate --config /app/Caddyfile --adapter caddyfile >/dev/null

bun /app/dist/server.js &
app_pid=$!
caddy run --config /app/Caddyfile --adapter caddyfile &
proxy_pid=$!

cleanup() {
  trap - INT TERM
  kill -TERM "$app_pid" "$proxy_pid" 2>/dev/null || true
  wait "$app_pid" "$proxy_pid" 2>/dev/null || true
}

trap 'cleanup; exit 0' INT TERM
set +e
wait -n "$app_pid" "$proxy_pid"
status=$?
set -e
cleanup
exit "$status"
