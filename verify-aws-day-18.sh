#!/usr/bin/env bash
# CloudPath — aws-day-18 verification.
# Usage:  bash verify-aws-day-18.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-aws-day-18.sh ABC234}"
LAB_ID="aws-day-18"
SECRET="__injected_by_deploy__"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/storage.txt"
c0=0; c1=0; c2=0; c3=0
[ -f "$FILE" ] && c0=1
line_is() {
  local got
  got="$(grep -i "^[[:space:]]*$1" "$FILE" 2>/dev/null | head -1 | tr 'A-Z' 'a-z')" || return 1
  case "$got" in *"$2"*) return 0 ;; *) return 1 ;; esac
}
if [ "$c0" -eq 1 ]; then
  line_is "website-images-served-to-visitors" "s3" && c1=1
  line_is "operating-system-disk-for-one-instance" "ebs" && c2=1
  line_is "shared-uploads-folder-for-five-web-servers" "efs" && c3=1
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
