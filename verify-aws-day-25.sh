#!/usr/bin/env bash
# CloudPath — aws-day-25 verification.
# Usage:  bash verify-aws-day-25.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-aws-day-25.sh ABC234}"
LAB_ID="aws-day-25"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/framework.txt"
c0=0; c1=0; c2=0; c3=0; c4=0
[ -f "$FILE" ] && c0=1
line_is() {
  local got
  got="$(grep -i "^[[:space:]]*$1" "$FILE" 2>/dev/null | head -1 | tr 'A-Z' 'a-z')" || return 1
  case "$got" in *"$2"*) return 0 ;; *) return 1 ;; esac
}
if [ "$c0" -eq 1 ]; then
  line_is "running-across-two-availability-zones" "reliability" && c1=1
  line_is "encrypting-customer-data-at-rest" "security" && c2=1
  line_is "shutting-down-idle-instances-to-save-money" "cost" && c3=1
  line_is "production-app-needing-24-7-phone-support" "business" && c4=1
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) | (c4 << 4) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
