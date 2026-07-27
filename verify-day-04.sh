#!/usr/bin/env bash
# CloudPath — day-04 verification (IAM least-privilege policy).
#
# Usage:  bash verify-day-04.sh <CODE>
#
# This PARSES the policy as JSON (via python3) rather than grepping for text,
# so a valid-but-unusually-formatted policy passes and a malformed one fails.
#
# Scope: this is the FAST LOCAL check — structure and wildcards only. The full
# IAM linter (grammar, action format, ARN shape, security findings) runs
# server-side in app/grading/iam.py and grades the same policy when it lands in
# the learner's repo on day 5. Validation you can't trust or update shouldn't
# live on the learner's machine. See docs/AWS_INTEGRATION.md.

set -euo pipefail

NONCE="${1:?Paste your day-4 code like:  bash verify-day-04.sh ABC234}"
LAB_ID="day-04"
SECRET="463aec013a1104e84f28fa7c534c3df0d13e48a86c770493cb66004bbb6e2de2"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/policy.json"

if ! command -v python3 >/dev/null 2>&1; then
  echo "This check needs python3, which isn't installed here." >&2
  echo "Tell your coach and we'll sort it out — your progress is safe." >&2
  exit 1
fi

# --- checks (order MUST match checks[] in day-04.yaml) ---
c0=0; c1=0; c2=0; c3=0

[ -f "$FILE" ] && c0=1

if [ "$c0" -eq 1 ]; then
  # python prints: "<valid_json> <allows_getobject> <no_wildcard>"
  read -r c1 c2 c3 <<<"$(python3 - "$FILE" <<'PY'
import json, sys

try:
    with open(sys.argv[1]) as fh:
        doc = json.load(fh)
except Exception:
    print("0 0 0")          # not valid JSON -> the other checks can't pass
    raise SystemExit

stmts = doc.get("Statement", []) if isinstance(doc, dict) else []
if isinstance(stmts, dict):
    stmts = [stmts]

allow_actions = []
all_actions = []
for st in stmts:
    if not isinstance(st, dict):
        continue
    act = st.get("Action", [])
    acts = [act] if isinstance(act, str) else [a for a in act if isinstance(a, str)]
    all_actions += acts
    if str(st.get("Effect", "")).lower() == "allow":
        allow_actions += acts

allows_get = any(a == "s3:GetObject" for a in allow_actions)
# a wildcard anywhere in an Allow is the mistake we're teaching against
no_wildcard = not any(a == "*" or a.endswith(":*") for a in allow_actions)
print(f"1 {int(allows_get)} {int(no_wildcard and bool(all_actions))}")
PY
)"
fi

# --- emit result token ---
bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"

echo "CP-${NONCE}-${bits_hex}-${hmac8}"
