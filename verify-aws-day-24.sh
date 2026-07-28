#!/usr/bin/env bash
# CloudPath — day-24 verification.
# Usage:  bash verify-day-24.sh <CODE>
set -euo pipefail
NONCE="${1:?Paste your code like:  bash verify-day-24.sh ABC234}"
LAB_ID="day-24"
SECRET="463aec013a1104e84f28fa7c534c3df0d13e48a86c770493cb66004bbb6e2de2"   # server injects GRADING_HMAC_SECRET
FILE="$HOME/cloudpath/alarm.json"
c0=0; c1=0; c2=0; c3=0; c4=0
[ -f "$FILE" ] && c0=1
if [ "$c0" -eq 1 ]; then
  command -v python3 >/dev/null 2>&1 || { echo "This check needs python3 — tell your coach." >&2; exit 1; }
  read -r c1 c2 c3 c4 <<<"$(python3 - "$FILE" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    print("0 0 0 0"); raise SystemExit
cpu = str(d.get("MetricName","")).lower() == "cpuutilization" and float(d.get("Threshold",-1)) == 80
period = int(d.get("Period",-1)) == 300
acts = d.get("AlarmActions", [])
if isinstance(acts, str): acts = [acts]
sns = any("sns" in str(a).lower() for a in acts)
print(f"1 {int(cpu)} {int(period)} {int(sns)}")
PY
)"
fi

bits=$(( c0 | (c1 << 1) | (c2 << 2) | (c3 << 3) | (c4 << 4) ))
bits_hex="$(printf '%x' "$bits")"
hmac8="$(printf '%s|%s|%s' "$LAB_ID" "$NONCE" "$bits_hex" \
  | openssl dgst -sha256 -hmac "$SECRET" | awk '{print substr($NF,1,8)}')"
echo "CP-${NONCE}-${bits_hex}-${hmac8}"
