#!/usr/bin/env bash
# CloudPath — day-08 verification.
# Usage:  bash verify-day-08.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-day-08.sh ABC234}"
LAB_ID="day-08"
SECRET="463aec013a1104e84f28fa7c534c3df0d13e48a86c770493cb66004bbb6e2de2"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/responsibility.txt"
c0=0; c1=0; c2=0; c3=0; c4=0
[ -f "$FILE" ] && c0=1
line_is() {  # line_is <label> <expected>
  local got
  got="$(grep -i "^[[:space:]]*$1" "$FILE" 2>/dev/null | head -1 | tr 'A-Z' 'a-z')" || return 1
  case "$got" in *"$2"*) return 0 ;; *) return 1 ;; esac
}
if [ "$c0" -eq 1 ]; then
  line_is "physical-datacenter-security" "aws"        && c1=1
  line_is "patching-your-ec2-operating-system" "customer" && c2=1
  line_is "hardware-failure-replacement" "aws"        && c3=1
  line_is "who-can-read-your-s3-bucket" "customer"    && c4=1
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) | (c4 << 4) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
