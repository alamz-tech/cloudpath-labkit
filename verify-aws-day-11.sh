#!/usr/bin/env bash
# CloudPath — aws-day-11 verification.
# Usage:  bash verify-aws-day-11.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-aws-day-11.sh ABC234}"
LAB_ID="aws-day-11"
SECRET="__injected_by_deploy__"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/encryption.json"
c0=0; c1=0; c2=0; c3=0
[ -f "$FILE" ] && c0=1
if [ "$c0" -eq 1 ]; then
  command -v python3 >/dev/null 2>&1 || { echo "This check needs python3 — tell your coach." >&2; exit 1; }
  read -r c1 c2 c3 <<<"$(python3 - "$FILE" <<'PY'
import json, sys
try:
    doc = json.load(open(sys.argv[1]))
except Exception:
    print("0 0 0"); raise SystemExit
blob = json.dumps(doc)
rules = doc.get("Rules") if isinstance(doc, dict) else None
if rules is None and isinstance(doc, dict):
    for v in doc.values():
        if isinstance(v, dict) and "Rules" in v: rules = v["Rules"]
has_rules = bool(rules) and "ApplyServerSideEncryptionByDefault" in blob
uses_kms = "aws:kms" in blob
print(f"1 {int(has_rules)} {int(uses_kms)}")
PY
)"
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
