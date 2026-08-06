#!/usr/bin/env bash
# CloudPath — aws-day-22 verification.
# Usage:  bash verify-aws-day-22.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-aws-day-22.sh ABC234}"
LAB_ID="aws-day-22"
SECRET="9f4381e664d6b7a7a758bb9cc1614ed7e64c65df23a75076ed79bf26544b12a6"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/security-group.json"
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
rules = doc.get("Rules", []) if isinstance(doc, dict) else []
if isinstance(rules, dict): rules = [rules]
def rule(port, src=None, not_src=None):
    for r in rules:
        if not isinstance(r, dict): continue
        if int(r.get("Port", -1)) != port: continue
        s = str(r.get("Source", ""))
        if src and s == src: return True
        if not_src and s != not_src: return True
    return False
https = rule(443, src="0.0.0.0/0")
ssh = rule(22, not_src="0.0.0.0/0")
print(f"1 {int(https)} {int(ssh)}")
PY
)"
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
