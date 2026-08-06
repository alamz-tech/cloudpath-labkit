#!/usr/bin/env bash
# CloudPath — gcp-day-20 verification script.
# Usage:  bash verify-gcp-day-20.sh <CODE>
#
# Inspects a real Docker build in your lab environment.
set -euo pipefail
NONCE="${1:?Paste your lesson-20 code like:  bash verify-gcp-day-20.sh ABC234}"
LAB_ID="gcp-day-20"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
DF="$HOME/cloudpath/app/Dockerfile"

c0=0; c1=0; c2=0; c3=0

[ -s "$DF" ] && c0=1

# check 1: the image actually builds. Rebuilt here rather than trusting an
# earlier build, so the file we inspect is the file that produced the image.
if [ "$c0" -eq 1 ] && command -v docker >/dev/null 2>&1; then
  if docker build -q -t cloudpath-verify "$HOME/cloudpath/app" >/dev/null 2>&1; then c1=1; fi
fi

# check 2: it does NOT run as root. Asked of the running container rather
# than grepped from the file — USER can be overridden later in the Dockerfile,
# and what matters is who the process actually is.
if [ "$c1" -eq 1 ]; then
  who="$(docker run --rm cloudpath-verify whoami 2>/dev/null || true)"
  if [ -n "$who" ] && [ "$who" != "root" ]; then c2=1; fi
fi

# check 3: no secret baked in. Deliberately narrow — matches assignments that
# look like credentials, not any mention of the words, so a comment explaining
# why secrets are bad doesn't fail the learner.
if [ "$c0" -eq 1 ]; then
  if ! grep -Eiq '^[[:space:]]*(ENV|ARG)[[:space:]]+[A-Z_]*(PASSWORD|SECRET|API_?KEY|TOKEN)[[:space:]]*=?[[:space:]]*[^[:space:]]+' "$DF"; then c3=1; fi
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
