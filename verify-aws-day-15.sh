#!/usr/bin/env bash
# CloudPath — day-15 verification.
# Usage:  bash verify-day-15.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-day-15.sh ABC234}"
LAB_ID="day-15"
SECRET="463aec013a1104e84f28fa7c534c3df0d13e48a86c770493cb66004bbb6e2de2"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/launch.txt"
c0=0; c1=0; c2=0; c3=0
[ -f "$FILE" ] && c0=1
if [ "$c0" -eq 1 ]; then
  grep -q "run-instances" "$FILE" && c1=1
  grep -Eq -- "--instance-type[[:space:]]+c5\\.large" "$FILE" && c2=1
  grep -Eq -- "--image-id[[:space:]]+ami-" "$FILE" && c3=1
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
