#!/usr/bin/env bash
# CloudPath — gcp-day-36 verification script.
# Usage:  bash verify-gcp-day-36.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your lesson-36 code like:  bash verify-gcp-day-36.sh ABC234}"
LAB_ID="gcp-day-36"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
F="$HOME/cloudpath/lesson36-pubsub.txt"

c0=0; c1=0; c2=0; c3=0; c4=0
[ -s "$F" ] && c0=1

# check 1: two consumers, comma separated, placeholder gone
if [ "$c0" -eq 1 ]; then
  s="$(grep -i '^subscriptions:' "$F" | cut -d: -f2- || true)"
  if [ -n "$s" ] && ! printf '%s' "$s" | grep -qi 'REPLACE' \
     && printf '%s' "$s" | grep -q ','; then c1=1; fi
fi

# check 2: the delivery guarantee, hyphenated or not
if [ "$c0" -eq 1 ] && grep -Eiq '^delivery:.*at[ -]?least[ -]?once' "$F"; then c2=1; fi

# check 3: idempotency keyed on the message id. Accept several phrasings —
# the idea matters, not the wording.
if [ "$c0" -eq 1 ] && grep -Eiq '^idempotency:.*(message[ _-]?id|msg[ _-]?id|messageid)' "$F"; then c3=1; fi

if [ "$c0" -eq 1 ] && grep -Eiq '^dead_letter:[[:space:]]*(yes|true)' "$F"; then c4=1; fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) | (c4 << 4) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
