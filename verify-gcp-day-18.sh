#!/usr/bin/env bash
# CloudPath — gcp-day-18 verification script.
# Usage:  bash verify-gcp-day-18.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your lesson-18 code like:  bash verify-gcp-day-18.sh ABC234}"
LAB_ID="gcp-day-18"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
F="$HOME/cloudpath/lesson18-db.txt"
c0=0; c1=0; c2=0; c3=0
[ -s "$F" ] && c0=1
if [ "$c0" -eq 1 ] && grep -Eiq '^engine:[[:space:]]*(mysql|postgres(ql)?|sqlserver|sql-server)' "$F"; then c1=1; fi
if [ "$c0" -eq 1 ] && grep -Eiq '^high_availability:[[:space:]]*(on|true|yes|enabled)' "$F"; then c2=1; fi
# check 3: private-ip or auth-proxy, and NOT public-ip. Both halves matter —
# a learner who wrote "private-ip but public-ip is fine too" has missed it.
if [ "$c0" -eq 1 ] \
   && grep -Eiq '^connection:[[:space:]]*(private-ip|private_ip|auth-proxy|auth_proxy)' "$F" \
   && ! grep -Eiq '^connection:.*public' "$F"; then c3=1; fi
bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
