#!/usr/bin/env bash
# CloudPath — gcp-day-13 verification script.
#
# Usage:  bash verify-gcp-day-13.sh <CODE>

set -euo pipefail

NONCE="${1:?Paste your lesson-13 code like:  bash verify-gcp-day-13.sh ABC234}"
LAB_ID="gcp-day-13"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
PLAN="$HOME/cloudpath/lesson13-plan.txt"

# --- checks (order MUST match checks[] in day-13.yaml) ---
c0=0; c1=0; c2=0; c3=0

[ -s "$PLAN" ] && c0=1

# check 1: a minimum of 2 or more, placeholder gone. Accept any number >= 2
# rather than exactly 2 — a learner who wrote 3 has understood the point.
if [ "$c0" -eq 1 ]; then
  m="$(grep -i '^min_instances:' "$PLAN" | sed 's/[^0-9]//g')"
  if [ -n "$m" ] && [ "$m" -ge 2 ] 2>/dev/null; then c1=1; fi
fi

# check 2: regional, not zonal
if [ "$c0" -eq 1 ] && grep -iq '^scope:.*regional' "$PLAN"; then c2=1; fi

# check 3: a path, not a bare port. Must start with a slash.
if [ "$c0" -eq 1 ] && grep -Eiq '^health_check_path:[[:space:]]*/[a-z0-9_-]+' "$PLAN"; then c3=1; fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
