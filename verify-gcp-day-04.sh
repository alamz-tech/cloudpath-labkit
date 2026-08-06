#!/usr/bin/env bash
# CloudPath — gcp-day-04 verification script.
#
# Usage:  bash verify-gcp-day-04.sh <CODE>
#
# Reads the two files you saved with --format. Check 1 is the one that matters:
# copying the worked example instead of varying it writes a region where an
# email should be, and fails there and only there.

set -euo pipefail

NONCE="${1:?Paste your lesson-4 code like:  bash verify-gcp-day-04.sh ABC234}"
LAB_ID="gcp-day-04"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
REGION="$HOME/cloudpath/lesson4-region.txt"
ACCOUNT="$HOME/cloudpath/lesson4-account.txt"

# --- checks (order MUST match checks[] in day-04.yaml) ---
c0=0; c1=0

# check 0: a region was saved. Accept any region name rather than a fixed
# list — Google adds regions, and a learner in Johannesburg should not fail
# for picking the one nearest to them.
if [ -s "$REGION" ]; then
  r="$(tr -d '[:space:]' < "$REGION")"
  if printf '%s' "$r" | grep -Eq '^[a-z]+-[a-z]+[0-9]+$'; then c0=1; fi
fi

# check 1: the account file holds an email address
if [ -s "$ACCOUNT" ]; then
  a="$(tr -d '[:space:]' < "$ACCOUNT")"
  if printf '%s' "$a" | grep -Eq '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'; then c1=1; fi
fi

# --- emit result token: CP-<nonce>-<bits_hex>-<hmac8> ---
bits=$(( c0 | (c1 << 1) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
