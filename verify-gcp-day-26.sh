#!/usr/bin/env bash
# CloudPath — gcp-day-26 verification script.
# Usage:  bash verify-gcp-day-26.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your lesson-26 code like:  bash verify-gcp-day-26.sh ABC234}"
LAB_ID="gcp-day-26"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
F="$HOME/cloudpath/lesson26-signals.txt"
c0=0; c1=0; c2=0; c3=0
[ -s "$F" ] && c0=1
# check 1: a percentile, not an average. Accept p90 upward — a learner who
# chose p90 has understood the point about tails.
if [ "$c0" -eq 1 ] && grep -Eiq '^latency_metric:.*p(9[0-9]|99\.[0-9])' "$F"; then c1=1; fi
if [ "$c0" -eq 1 ] && grep -Eiq '^error_signal:[[:space:]]*rate' "$F"; then c2=1; fi
if [ "$c0" -eq 1 ] && grep -Eiq '^uptime_check:[[:space:]]*(yes|true)' "$F"; then c3=1; fi
bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
