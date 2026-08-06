#!/usr/bin/env bash
# CloudPath — gcp-day-09 verification script.
#
# Usage:  bash verify-gcp-day-09.sh <CODE>

set -euo pipefail

NONCE="${1:?Paste your lesson-9 code like:  bash verify-gcp-day-09.sh ABC234}"
LAB_ID="gcp-day-09"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
DISK="$HOME/cloudpath/lesson9-disktype.txt"
NOTES="$HOME/cloudpath/lesson9-notes.txt"

# --- checks (order MUST match checks[] in day-09.yaml) ---
c0=0; c1=0; c2=0

# check 0: a persistent disk type. Accept any pd-* rather than pd-balanced
# alone — a learner whose zone lacks it should be able to save what it does
# offer without failing.
if [ -s "$DISK" ]; then
  grep -Eqi 'pd-[a-z]+' "$DISK" && c0=1
fi

# check 1: the notes file exists at all
[ -s "$NOTES" ] && c1=1

# check 2: they replaced the placeholders AND covered both ideas. Checking
# for the placeholder is the important half: a learner who pastes the block
# and stops has a file that would otherwise look complete.
if [ "$c1" -eq 1 ]; then
  if ! grep -q 'REPLACE THIS' "$NOTES" \
     && grep -qi 'backup' "$NOTES" \
     && grep -qi 'template' "$NOTES"; then
    c2=1
  fi
fi

# --- emit result token: CP-<nonce>-<bits_hex>-<hmac8> ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
