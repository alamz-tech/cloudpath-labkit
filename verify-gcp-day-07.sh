#!/usr/bin/env bash
# CloudPath — gcp-day-07 verification script.
#
# Usage:  bash verify-gcp-day-07.sh <CODE>
#
# Reads the three files you saved. Nothing here contacts Google or creates
# anything — the lesson is deliberately free.

set -euo pipefail

NONCE="${1:?Paste your lesson-7 code like:  bash verify-gcp-day-07.sh ABC234}"
LAB_ID="gcp-day-07"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
MACHINE="$HOME/cloudpath/lesson7-machine.txt"
IMAGE="$HOME/cloudpath/lesson7-image.txt"
INSTANCES="$HOME/cloudpath/lesson7-instances.txt"

# --- checks (order MUST match checks[] in day-07.yaml) ---
c0=0; c1=0; c2=0

# check 0: a machine type name. Accept any Google machine type shape
# (family-class-size, e.g. e2-micro, n2-standard-8) rather than only e2-micro
# — a learner whose zone lacks e2-micro must not be failed for adapting.
if [ -s "$MACHINE" ]; then
  m="$(tr -d '[:space:]' < "$MACHINE")"
  printf '%s' "$m" | grep -Eq '^[a-z][0-9]?[a-z]*-[a-z0-9]+(-[a-z0-9]+)*$' && c0=1
fi

# check 1: a Debian image family. Matched loosely on "debian" so a learner
# picking debian-11, debian-12 or a newer line all pass — pinning one would
# fail people the day Google publishes the next release.
if [ -s "$IMAGE" ]; then
  grep -qi 'debian' "$IMAGE" && c1=1
fi

# check 2: they ran the instances-list command. An EMPTY list is the expected
# answer, so the file existing is the whole check — we are confirming the
# habit, not the result.
[ -f "$INSTANCES" ] && c2=1

# --- emit result token: CP-<nonce>-<bits_hex>-<hmac8> ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
