#!/usr/bin/env bash
# r10v90 — the MUST-STAY control battery: build each named earlier-pass arm
# with a FRESH Surelog golden and with both frozen binaries in BOTH views, and
# report the ct90cen 3-way verdict + the TYPESPEC-ONLY verdict.
set -u
export CEN90=/tmp/v90_arms/ct90cen PRIS=/tmp/v90_pristine.bin
PATCHED=${PATCHED:?}
export PATCHED
OUT=${OUT:-/tmp/v90_ctl}
mkdir -p "$OUT"
: > "$OUT/SUMMARY.txt"
while IFS= read -r f <&3; do
  [ -f "$f" ] || continue
  tag=$(echo "$f" | sed 's|.*/tools/probe/||; s|/|__|g; s|\.sv$||')
  d="$OUT/$tag"; rm -rf "$d"; mkdir -p "$d"
  bash /tmp/v90_arms/varm90.sh "$f" "$d" > "$d/run.log" 2>&1 </dev/null
  mkdir -p "$d/elab"; cp "$d/g.rows" "$d/elab/g.rows" 2>/dev/null
  cp "$d/oe.rows" "$d/elab/o.rows" 2>/dev/null; cp "$d/qe.rows" "$d/elab/q.rows" 2>/dev/null
  {
    echo "== $tag"
    grep -E '^(SL|pris|patc|prisE|patcE) ' "$d/run.log"
    echo "-- plain (payload) --"; python3 /tmp/wt_v90/tools/probe/r10earl90repro/score3_90.py "$d" 2>&1 >/dev/null
    echo "-- plain (typespec only) --"; python3 /tmp/v90_arms/tsonly90.py "$d"
    echo "-- elab (typespec only) --"; python3 /tmp/v90_arms/tsonly90.py "$d/elab"
  } >> "$OUT/SUMMARY.txt" 2>&1
done 3< "$1"
