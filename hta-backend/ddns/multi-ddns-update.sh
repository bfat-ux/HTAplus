#!/usr/bin/env bash
#
# multi-ddns-update.sh (v3 — Cloudflare)
set -euo pipefail

CF_API="https://api.cloudflare.com/client/v4"
TTL="${TTL:-60}"
IP_CHECK_URL="${IP_CHECK_URL:-https://api.ipify.org}"
STATE_FILE="${STATE_FILE:-/var/lib/hta-ddns/last-ip}"

log()  { echo "[multi-ddns] $(date -Iseconds) $*"; }
info() { log "  OK  $*"; }
err()  { log "  ERR $*"; }

if [[ -z "${CF_TOKEN:-}" ]]; then
  log "ERROR: CF_TOKEN must be set in /etc/hta-ddns.env"
  exit 2
fi

if [[ -z "${DDNS_RECORDS:-}" ]]; then
  log "ERROR: DDNS_RECORDS must be set in /etc/hta-ddns.env"
  exit 2
fi

RECORDS=( ${DDNS_RECORDS} )

if ! CURRENT_IP=$(curl -fsS --max-time 10 "$IP_CHECK_URL"); then
  log "ERROR: could not reach $IP_CHECK_URL"
  exit 1
fi

if ! [[ "$CURRENT_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  log "ERROR: invalid IP returned: '$CURRENT_IP'"
  exit 1
fi

mkdir -p "$(dirname "$STATE_FILE")"
LAST_IP=""
LAST_RECORDS=""
[[ -f "$STATE_FILE" ]]            && LAST_IP=$(cat "$STATE_FILE")
[[ -f "${STATE_FILE}.records" ]]  && LAST_RECORDS=$(cat "${STATE_FILE}.records")
CURRENT_RECORDS_STR="${RECORDS[*]}"

if [[ "$CURRENT_IP" == "$LAST_IP" && "$CURRENT_RECORDS_STR" == "$LAST_RECORDS" ]]; then
  exit 0
fi

log "IP change: ${LAST_IP:-<none>} → $CURRENT_IP. Updating ${#RECORDS[@]} record(s)..."

AUTH_HEADER="Authorization: Bearer $CF_TOKEN"
declare -A ZONE_CACHE

get_zone_id() {
  local domain="$1"
  if [[ -n "${ZONE_CACHE[$domain]:-}" ]]; then
    echo "${ZONE_CACHE[$domain]}"
    return
  fi
  local resp zone_id
  resp=$(curl -fsS --max-time 15 -H "$AUTH_HEADER" "$CF_API/zones?name=${domain}&status=active" || echo "")
  zone_id=$(printf '%s' "$resp" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(d['result'][0]['id'] if d.get('result') else '')" 2>/dev/null || echo "")
  ZONE_CACHE[$domain]="$zone_id"
  echo "$zone_id"
}

get_record_id() {
  local zone_id="$1" fqdn="$2" resp
  resp=$(curl -fsS --max-time 15 -H "$AUTH_HEADER" \
    "$CF_API/zones/${zone_id}/dns_records?type=A&name=${fqdn}" || echo "")
  printf '%s' "$resp" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(d['result'][0]['id'] if d.get('result') else '')" \
    2>/dev/null || echo ""
}

ANY_ERROR=0

for spec in "${RECORDS[@]}"; do
  REC_DOMAIN="${spec%%/*}"
  REC_NAME="${spec#*/}"
  [[ "$REC_NAME" == "@" ]] && FQDN="$REC_DOMAIN" || FQDN="${REC_NAME}.${REC_DOMAIN}"

  ZONE_ID=$(get_zone_id "$REC_DOMAIN")
  if [[ -z "$ZONE_ID" ]]; then
    err "$FQDN — zone not found in Cloudflare"
    ANY_ERROR=1; continue
  fi

  RECORD_ID=$(get_record_id "$ZONE_ID" "$FQDN")
  if [[ -z "$RECORD_ID" ]]; then
    err "$FQDN — A record not found. Create a placeholder in CF dashboard first."
    ANY_ERROR=1; continue
  fi

  RESP_FILE=$(mktemp)
  HTTP_CODE=$(curl -sS --max-time 15 \
    -o "$RESP_FILE" -w "%{http_code}" \
    -X PATCH \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    --data "{\"content\":\"$CURRENT_IP\",\"ttl\":$TTL}" \
    "$CF_API/zones/${ZONE_ID}/dns_records/${RECORD_ID}" || echo "000")

  case "$HTTP_CODE" in
    200) info "$FQDN → $CURRENT_IP" ;;
    401|403)
      err "$FQDN — CF rejected token (HTTP $HTTP_CODE)"
      rm -f "$RESP_FILE"; exit 2 ;;
    *)
      err "$FQDN — HTTP $HTTP_CODE: $(cat "$RESP_FILE")"
      ANY_ERROR=1 ;;
  esac
  rm -f "$RESP_FILE"
done

if [[ "$ANY_ERROR" -eq 0 ]]; then
  echo "$CURRENT_IP"          > "$STATE_FILE"
  echo "$CURRENT_RECORDS_STR" > "${STATE_FILE}.records"
  log "${#RECORDS[@]} record(s) updated successfully."
  exit 0
else
  log "Some record(s) failed — will retry on next timer run."
  exit 1
fi
