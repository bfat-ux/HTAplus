#!/usr/bin/env bash
#
# hta-ddns-update.sh
#
# Updates the api.htaplus.com A record at GoDaddy whenever the Pi's
# home public IP changes. Designed to be run by a systemd timer every
# few minutes.
#
# Required env vars (loaded from /etc/hta-ddns.env by the systemd unit):
#   GODADDY_KEY      Production API key from https://developer.godaddy.com/keys
#   GODADDY_SECRET   Corresponding API secret
#
# Optional env vars (with defaults):
#   DOMAIN           Base domain at GoDaddy                (default: htaplus.com)
#   RECORD_NAME      Subdomain label to keep updated       (default: api)
#   TTL              Record TTL in seconds                 (default: 600)
#   IP_CHECK_URL     Public-IP lookup URL                  (default: https://api.ipify.org)
#   STATE_FILE       Path to last-known-IP cache file      (default: /var/lib/hta-ddns/last-ip)
#
# Exit codes:
#   0  success (either no change needed, or update applied)
#   1  transient / retryable error (network, API 5xx, invalid IP)
#   2  configuration error (missing credentials, bad TTL, etc.)

set -euo pipefail

DOMAIN="${DOMAIN:-htaplus.com}"
RECORD_NAME="${RECORD_NAME:-api}"
TTL="${TTL:-600}"
IP_CHECK_URL="${IP_CHECK_URL:-https://api.ipify.org}"
STATE_FILE="${STATE_FILE:-/var/lib/hta-ddns/last-ip}"

log() { echo "[hta-ddns] $(date -Iseconds) $*"; }

if [[ -z "${GODADDY_KEY:-}" || -z "${GODADDY_SECRET:-}" ]]; then
  log "ERROR: GODADDY_KEY and GODADDY_SECRET must be set (check /etc/hta-ddns.env)"
  exit 2
fi

# --- 1. Detect current public IP --------------------------------------------
if ! CURRENT_IP=$(curl -fsS --max-time 10 "$IP_CHECK_URL"); then
  log "ERROR: could not reach $IP_CHECK_URL to determine public IP"
  exit 1
fi
if ! [[ "$CURRENT_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  log "ERROR: invalid public IP returned: '$CURRENT_IP'"
  exit 1
fi

# --- 2. Fast path: skip if local cache matches ------------------------------
mkdir -p "$(dirname "$STATE_FILE")"
LAST_IP=""
if [[ -f "$STATE_FILE" ]]; then
  LAST_IP=$(cat "$STATE_FILE")
fi
if [[ "$CURRENT_IP" == "$LAST_IP" ]]; then
  # No change since last successful run. Silent exit to keep logs clean.
  exit 0
fi

# --- 3. Compare with what GoDaddy actually has ------------------------------
AUTH="sso-key ${GODADDY_KEY}:${GODADDY_SECRET}"
API_URL="https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/${RECORD_NAME}"

REMOTE_BODY=$(curl -fsS --max-time 15 -H "Authorization: $AUTH" "$API_URL" || echo "")
REMOTE_IP=$(printf '%s' "$REMOTE_BODY" \
  | python3 -c "import sys, json; d=json.load(sys.stdin); print(d[0]['data'] if d else '')" 2>/dev/null \
  || echo "")

if [[ -z "$REMOTE_IP" ]]; then
  log "WARNING: could not read current record from GoDaddy (response: $REMOTE_BODY). Will attempt update anyway."
elif [[ "$CURRENT_IP" == "$REMOTE_IP" ]]; then
  log "Public IP $CURRENT_IP already matches GoDaddy. Refreshing local cache."
  echo "$CURRENT_IP" > "$STATE_FILE"
  exit 0
fi

# --- 4. Apply the update ----------------------------------------------------
log "IP change detected: ${REMOTE_IP:-<unknown>} -> $CURRENT_IP. Updating GoDaddy..."

RESP_FILE=$(mktemp)
trap 'rm -f "$RESP_FILE"' EXIT

HTTP_CODE=$(curl -sS --max-time 15 -o "$RESP_FILE" -w "%{http_code}" \
  -X PUT \
  -H "Authorization: $AUTH" \
  -H "Content-Type: application/json" \
  --data "[{\"data\":\"$CURRENT_IP\",\"ttl\":$TTL}]" \
  "$API_URL" || echo "000")

case "$HTTP_CODE" in
  200)
    log "Update successful. ${RECORD_NAME}.${DOMAIN} -> $CURRENT_IP (ttl ${TTL}s)"
    echo "$CURRENT_IP" > "$STATE_FILE"
    ;;
  401|403)
    log "ERROR: GoDaddy rejected credentials (HTTP $HTTP_CODE). Check GODADDY_KEY / GODADDY_SECRET are PRODUCTION keys."
    exit 2
    ;;
  404)
    log "ERROR: GoDaddy says record does not exist (HTTP 404). Verify DOMAIN='$DOMAIN' and RECORD_NAME='$RECORD_NAME'."
    exit 2
    ;;
  *)
    log "ERROR: GoDaddy API returned HTTP $HTTP_CODE: $(cat "$RESP_FILE")"
    exit 1
    ;;
esac
