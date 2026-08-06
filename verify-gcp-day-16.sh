#!/usr/bin/env bash
# CloudPath — gcp-day-16 verification script.
# Usage:  bash verify-gcp-day-16.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your lesson-16 code like:  bash verify-gcp-day-16.sh ABC234}"
LAB_ID="gcp-day-16"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
F="$HOME/cloudpath/lesson16-bucket.txt"
c0=0; c1=0; c2=0; c3=0
[ -s "$F" ] && c0=1

# check 1: lowercase, hyphenated, not a placeholder and not an obvious name.
if [ "$c0" -eq 1 ]; then
  n="$(grep -i '^bucket_name:' "$F" | cut -d: -f2- | tr -d '[:space:]')"
  if printf '%s' "$n" | grep -Eq '^[a-z0-9][a-z0-9._-]{2,62}$' \
     && printf '%s' "$n" | grep -q -- '-' \
     && ! printf '%s' "$n" | grep -qi 'replace'; then c1=1; fi
fi

# check 2: a real location type
if [ "$c0" -eq 1 ] && grep -Eiq '^location_type:[[:space:]]*(regional|dual-region|multi-region)' "$F"; then c2=1; fi

# check 3: BOTH safety settings on. Checked together because either alone
# leaves the hole this lesson is about.
if [ "$c0" -eq 1 ] \
   && grep -Eiq '^uniform_access:[[:space:]]*(on|true|yes|enabled)' "$F" \
   && grep -Eiq '^public_access_prevention:[[:space:]]*(on|true|yes|enforced|enabled)' "$F"; then c3=1; fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
