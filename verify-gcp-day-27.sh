#!/usr/bin/env bash
# CloudPath — gcp-day-27 verification script.
# Usage:  bash verify-gcp-day-27.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your lesson-27 code like:  bash verify-gcp-day-27.sh ABC234}"
LAB_ID="gcp-day-27"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
F="$HOME/cloudpath/lesson27-logs.txt"
c0=0; c1=0; c2=0; c3=0
if [ -s "$F" ] && grep -q '^unstructured:' "$F"; then c0=1; fi
s="$(grep '^structured:' "$F" 2>/dev/null | cut -d: -f2-)"
# check 1: JSON — braces and at least one quoted key
if [ "$c0" -eq 1 ] && ! printf '%s' "$s" | grep -qi 'REPLACE'; then
  if printf '%s' "$s" | grep -q '{' && printf '%s' "$s" | grep -Eq '"[a-z_]+"[[:space:]]*:'; then c1=1; fi
fi
# check 2: the ids are NAMED fields. Any snake_case key holding a number.
if [ "$c1" -eq 1 ] && printf '%s' "$s" | grep -Eq '"[a-z]+_?[a-z]*(id|_id)"[[:space:]]*:[[:space:]]*"?[0-9]+' ; then c2=1; fi
if [ "$c0" -eq 1 ]; then
  e="$(grep '^exclusion:' "$F" 2>/dev/null | cut -d: -f2-)"
  if [ -n "$e" ] && ! printf '%s' "$e" | grep -qi 'REPLACE'; then c3=1; fi
fi
bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
