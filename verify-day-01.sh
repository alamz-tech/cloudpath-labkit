#!/usr/bin/env bash
# CloudPath — day-01 verification script.
#
# Usage:  bash verify-day-01.sh <CODE>
# where <CODE> is the one-time code the coach sent you.
#
# It inspects real state in your lab environment, then prints a result token
# for you to paste back to the coach. It never uploads anything itself.
#
# NOTE (honest): SECRET below ships inside this script, so this is pilot-grade
# integrity — tamper-evident against casual editing, not unforgeable. Your
# per-attempt CODE is what stops you from reusing someone else's result.

set -euo pipefail

NONCE="${1:?Paste your day-1 code like:  bash verify-day-01.sh ABC234}"
LAB_ID="day-01"
SECRET="463aec013a1104e84f28fa7c534c3df0d13e48a86c770493cb66004bbb6e2de2"   # server sets this to GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/day1.txt"

# --- checks (order MUST match checks[] in day-01.yaml) ---
c0=0; c1=0; c2=0

# check 0: file exists
[ -f "$FILE" ] && c0=1

# check 1: file contains the kernel name (Linux)
if [ "$c0" -eq 1 ] && grep -q "Linux" "$FILE"; then c1=1; fi

# check 2: permissions are 600 (owner-only) — least privilege
if [ "$c0" -eq 1 ]; then
  perm="$(stat -c '%a' "$FILE" 2>/dev/null || stat -f '%A' "$FILE")"
  [ "$perm" = "600" ] && c2=1
fi

# --- emit result token: CP-<nonce>-<bits_hex>-<hmac8> ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
