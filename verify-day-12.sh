#!/usr/bin/env bash
# CloudPath — day-12 verification.
# Usage:  bash verify-day-12.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-day-12.sh ABC234}"
LAB_ID="day-12"
SECRET="463aec013a1104e84f28fa7c534c3df0d13e48a86c770493cb66004bbb6e2de2"   # server injects GRADING_HMAC_SECRET
LOG="$HOME/cloudpath/trail.log"
FIND="$HOME/cloudpath/finding.txt"
c0=0; c1=0; c2=0
[ -f "$LOG" ] && c0=1
[ -f "$FIND" ] && c1=1
if [ "$c1" -eq 1 ] && grep -qi "temp-svc" "$FIND"; then c2=1; fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
