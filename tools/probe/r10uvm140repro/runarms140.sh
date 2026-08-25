#!/usr/bin/env bash
# r10uvm140 — build + census + score every g140_* arm in BOTH views.
# MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.
#   usage: PRIS=.. PATCHED=.. runarms140.sh <outroot>
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outroot}; mkdir -p "$OUT"
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
for f in "$HERE"/g140_*.sv; do
  b=$(basename "$f" .sv)
  D="$OUT/$b"
  PRIS="$PRIS" PATCHED="${PATCHED:-}" bash "$HERE/arm140.sh" "$f" "$D" 2>&1 | sed "s/^/[$b] /"
  for t in g ge o oe q qe; do
    [ -f "$D/$t.uhdm" ] || continue
    "$DUMP" "$D/$t.uhdm" > "$D/$t.dump" 2>&1
    python3 "$HERE/cen140.py" "$D/$t.dump" > "$D/$t.ret"
  done
  python3 "$HERE/score140.py" "$D" def
  python3 "$HERE/score140.py" "$D" elab
done
