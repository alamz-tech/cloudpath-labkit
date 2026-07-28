#!/usr/bin/env bash
# CloudPath — aws-day-10 verification.
# Usage:  bash verify-aws-day-10.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-aws-day-10.sh ABC234}"
LAB_ID="aws-day-10"
SECRET="__injected_by_deploy__"   # server injects GRADING_HMAC_SECRET
SH="$HOME/cloudpath/backup.sh"
ENV="$HOME/cloudpath/.env"
GI="$HOME/cloudpath/.gitignore"
c0=0; c1=0; c2=0; c3=0
[ -f "$SH" ] && c0=1
# the key must be GONE from the script
if [ "$c0" -eq 1 ] && ! grep -q "AKIA" "$SH"; then c1=1; fi
[ -f "$ENV" ] && c2=1
if [ -f "$GI" ] && grep -q "\.env" "$GI"; then c3=1; fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
