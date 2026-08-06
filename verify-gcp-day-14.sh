#!/usr/bin/env bash
# CloudPath — gcp-day-14 verification script.
#
# Usage:  bash verify-gcp-day-14.sh <CODE>

set -euo pipefail

NONCE="${1:?Paste your lesson-14 code like:  bash verify-gcp-day-14.sh ABC234}"
LAB_ID="gcp-day-14"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
REC="$HOME/cloudpath/lesson14-records.txt"

# --- checks (order MUST match checks[] in day-14.yaml) ---
c0=0; c1=0; c2=0

# check 0: file exists AND still holds the worked example, so the learner
# added a line rather than replacing the whole file.
if [ -s "$REC" ] && grep -Eq '^www[[:space:]]+A[[:space:]]' "$REC"; then c0=1; fi

# check 1: a CNAME for api pointing at a NAME. Placeholder must be gone.
if [ "$c0" -eq 1 ] && ! grep -q 'REPLACE-THIS-LINE' "$REC"; then
  if grep -Eiq '^api[[:space:]]+CNAME[[:space:]]+[0-9]+[[:space:]]+[a-z0-9.-]+\.[a-z]+' "$REC"; then c1=1; fi
fi

# check 2: the new record's TTL is short. Anything <= 600 counts — 300 is what
# the steps ask for, but a learner who chose 60 understood it better, not worse.
if [ "$c1" -eq 1 ]; then
  ttl="$(grep -Ei '^api[[:space:]]+CNAME' "$REC" | awk '{print $3}')"
  if [ -n "$ttl" ] && [ "$ttl" -le 600 ] 2>/dev/null; then c2=1; fi
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
