#!/usr/bin/env bash
# CloudPath — gcp-day-03 verification script.
#
# Usage:  bash verify-gcp-day-03.sh <CODE>
#
# Checks the two files you saved, NOT your live Google Cloud state — so it
# works whether or not you have a billing account, and costs nothing to run.

set -euo pipefail

NONCE="${1:?Paste your lesson-3 code like:  bash verify-gcp-day-03.sh ABC234}"
LAB_ID="gcp-day-03"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
PROJ="$HOME/cloudpath/lesson3-project.txt"
NUM="$HOME/cloudpath/lesson3-number.txt"

# --- checks (order MUST match checks[] in day-03.yaml) ---
c0=0; c1=0; c2=0

# check 0: the project file exists and has something in it
[ -s "$PROJ" ] && c0=1

# check 1: it looks like a real project ID rather than "(unset)" or an error.
# Google project IDs are 6-30 chars: lowercase letters, digits and hyphens,
# starting with a letter. Deliberately not stricter than that — a learner's
# real ID must never be rejected by our own regex.
if [ "$c0" -eq 1 ]; then
  id="$(tr -d '[:space:]' < "$PROJ")"
  if printf '%s' "$id" | grep -Eq '^[a-z][a-z0-9-]{5,29}$'; then c1=1; fi
fi

# check 2: the number file contains digits only — the project NUMBER, which
# is what distinguishes it from the ID the learner saved above.
if [ -s "$NUM" ]; then
  n="$(tr -d '[:space:]' < "$NUM")"
  if printf '%s' "$n" | grep -Eq '^[0-9]+$'; then c2=1; fi
fi

# --- emit result token: CP-<nonce>-<bits_hex>-<hmac8> ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
