#!/usr/bin/env bash
# CloudPath — gcp-day-11 verification script.
#
# Usage:  bash verify-gcp-day-11.sh <CODE>
#
# Reads the two files you saved. Nothing here creates or costs anything.

set -euo pipefail

NONCE="${1:?Paste your lesson-11 code like:  bash verify-gcp-day-11.sh ABC234}"
LAB_ID="gcp-day-11"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
NETS="$HOME/cloudpath/lesson11-networks.txt"
CIDR="$HOME/cloudpath/lesson11-cidr.txt"

# --- checks (order MUST match checks[] in day-11.yaml) ---
c0=0; c1=0; c2=0

# check 0: at least one network name saved. Accept any name — a learner may
# have created their own network, and requiring "default" would fail them.
if [ -s "$NETS" ] && grep -Eq '^[a-z][a-z0-9-]*$' "$NETS"; then c0=1; fi

# check 1: a CIDR range. Any valid-looking range, not a fixed one — subnet
# ranges differ per project and per region.
if [ -s "$CIDR" ] && grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$' "$CIDR"; then c1=1; fi

# check 2: the variation was actually made. Copying the networks line unchanged
# writes names into both files and fails HERE — an instructive failure.
if [ "$c0" -eq 1 ] && [ "$c1" -eq 1 ]; then
  if ! grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}/' "$NETS"; then c2=1; fi
fi

# --- emit result token: CP-<nonce>-<bits_hex>-<hmac8> ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
