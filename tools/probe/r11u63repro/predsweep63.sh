#!/bin/bash
# r11u63 — run predict63 over every slang.uhdm in a verify_golden workdir.
# WD is a PARAMETER (never hard-coded): predsweep63.sh <workdir> <out>
set -u
WD=${1:?workdir}; OUT=${2:?out}
P=${PREDICT63:-/tmp/r11u63_probe/predict63}
[ -x "$P" ] || { echo "FATAL: no predict63 at $P"; exit 3; }
: > "$OUT"
n=0; scanned=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    f="$d/slang.uhdm"
    [ -f "$f" ] || continue
    scanned=$((scanned+1))
    b=$(basename "$d"); b=${b%-*}
    "$P" "$f" "$mode/$b" >> "$OUT" 2>/dev/null
  done
done
echo "SCANNED $scanned" >> "$OUT"
grep '^HITS' "$OUT" | awk '$3>0' | sort > "$OUT.named"
echo "SCANNED=$scanned  ARMS-WITH-CANDIDATES=$(grep -c . "$OUT.named" || true)"
