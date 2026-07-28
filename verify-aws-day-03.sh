#!/usr/bin/env bash
# CloudPath — aws-day-03 verification (core AWS services cheat sheet).
#
# Usage:  bash verify-aws-day-03.sh <CODE>
# Checks ~/cloudpath/services.txt maps each of the four jobs to a real service.

set -euo pipefail

NONCE="${1:?Paste your day-3 code like:  bash verify-aws-day-03.sh ABC234}"
LAB_ID="aws-day-03"
SECRET="__injected_by_deploy__"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/services.txt"

# --- checks (order MUST match checks[] in day-03.yaml) ---
c0=0; c1=0; c2=0; c3=0; c4=0

# helper: does the line starting with <label> mention any of the given services?
line_has() {
  local label="$1"; shift
  local line
  line="$(grep -i "^[[:space:]]*${label}" "$FILE" 2>/dev/null | head -1 | tr 'A-Z' 'a-z')" || return 1
  [ -n "$line" ] || return 1
  local svc
  for svc in "$@"; do
    case "$line" in *"$svc"*) return 0 ;; esac
  done
  return 1
}

[ -f "$FILE" ] && c0=1

if [ "$c0" -eq 1 ]; then
  # accept the obvious right answers; ec2/lambda both legitimately "compute"
  line_has compute    "ec2" "lambda"        && c1=1
  line_has storage    "s3"                  && c2=1
  line_has database   "rds"                 && c3=1
  line_has networking "vpc" "route 53" "route53" && c4=1
fi

# --- emit result token ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) | (c4 << 4) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
