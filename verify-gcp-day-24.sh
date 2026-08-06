#!/usr/bin/env bash
# CloudPath — gcp-day-24 verification script.
# Usage:  bash verify-gcp-day-24.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your lesson-24 code like:  bash verify-gcp-day-24.sh ABC234}"
LAB_ID="gcp-day-24"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
F="$HOME/cloudpath/lesson24-deployment.yaml"
c0=0; c1=0; c2=0; c3=0
if [ -s "$F" ] && grep -q 'kind:[[:space:]]*Deployment' "$F"; then c0=1; fi
if [ "$c0" -eq 1 ]; then
  r="$(grep -E '^[[:space:]]*replicas:' "$F" | head -1 | sed 's/[^0-9]//g')"
  if [ -n "$r" ] && [ "$r" -ge 2 ] 2>/dev/null; then c1=1; fi
fi
# Allow the list-dash form too ("- image: x"), and never let a miss kill the
# script — set -e on a failed grep would leave the learner with no token at
# all, which looks like the lab is broken rather than incomplete.
img="$(grep -E '^[[:space:]]*-?[[:space:]]*image:' "$F" 2>/dev/null | head -1 | sed 's/.*image:[[:space:]]*//' || true)"
tag="${img##*:}"
# check 2: the tag was changed from the worked example's v1
if [ "$c0" -eq 1 ] && [ -n "$tag" ] && [ "$tag" != "v1" ]; then c2=1; fi
# check 3: and it is not :latest — a movable tag records nothing
if [ "$c0" -eq 1 ] && [ "$(printf '%s' "$tag" | tr 'A-Z' 'a-z')" != "latest" ]; then c3=1; fi
bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
