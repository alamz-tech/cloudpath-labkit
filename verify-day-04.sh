#!/usr/bin/env bash
# CloudPath — day-04 verification (IAM least-privilege policy).
#
# Usage:  bash verify-day-04.sh <CODE>
# Checks ~/cloudpath/policy.json and prints a result token to paste back.

set -euo pipefail

NONCE="${1:?Paste your day-4 code like:  bash verify-day-04.sh ABC234}"
LAB_ID="day-04"
SECRET="463aec013a1104e84f28fa7c534c3df0d13e48a86c770493cb66004bbb6e2de2"   # server sets this to GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/policy.json"

# --- checks (order MUST match checks[] in day-04.yaml) ---
c0=0; c1=0; c2=0

# check 0: policy.json exists
[ -f "$FILE" ] && c0=1

# check 1: grants s3:GetObject
if [ "$c0" -eq 1 ] && grep -q 's3:GetObject' "$FILE"; then c1=1; fi

# check 2: NO wildcard action ("*" or "s3:*" as an Action value) — least privilege
if [ "$c0" -eq 1 ]; then
  if grep -Eq '"Action"[[:space:]]*:[[:space:]]*"(\*|s3:\*)"' "$FILE" \
     || grep -Eq '"(\*|s3:\*)"' "$FILE"; then
    c2=0
  else
    c2=1
  fi
fi

# --- emit result token ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
