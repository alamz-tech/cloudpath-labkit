#!/usr/bin/env bash
# CloudPath — gcp-day-22 verification script.
# Usage:  bash verify-gcp-day-22.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your lesson-22 code like:  bash verify-gcp-day-22.sh ABC234}"
LAB_ID="gcp-day-22"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server sets this to GRADING_HMAC_SECRET
F="$HOME/cloudpath/lesson22-images.txt"

c0=0; c1=0; c2=0; c3=0

# check 0: file exists AND still holds the worked example, so they added
# rather than replaced.
if [ -s "$F" ] && grep -q '^example:.*pkg\.dev/' "$F"; then c0=1; fi

# check 1: a full five-part path on the 'mine' line, placeholder gone.
mine="$(grep '^mine:' "$F" 2>/dev/null | cut -d: -f2- | tr -d '[:space:]')"
if [ "$c0" -eq 1 ] && ! printf '%s' "$mine" | grep -qi 'REPLACE'; then
  if printf '%s' "$mine" | grep -Eq '^[a-z0-9-]+-docker\.pkg\.dev/[a-z0-9-]+/[a-z0-9-]+/[a-z0-9-]+:[A-Za-z0-9._-]+$'; then c1=1; fi
fi

# check 2: the tag is not 'latest'. Only meaningful once there IS a tag.
if [ "$c1" -eq 1 ]; then
  tag="${mine##*:}"
  if [ "$(printf '%s' "$tag" | tr 'A-Z' 'a-z')" != "latest" ]; then c2=1; fi
fi

# check 3: digest explained in their own words. Requires the placeholder gone
# and something about content or immutability, not a fixed phrase.
if [ "$c0" -eq 1 ]; then
  d="$(grep '^digest_why:' "$F" 2>/dev/null | cut -d: -f2-)"
  if [ -n "$d" ] && ! printf '%s' "$d" | grep -qi 'REPLACE' \
     && printf '%s' "$d" | grep -Eqi 'content|immutable|cannot be moved|can not be moved|never changes|unique'; then c3=1; fi
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
