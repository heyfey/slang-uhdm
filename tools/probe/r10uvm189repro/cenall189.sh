#!/usr/bin/env bash
# r10uvm189repro/cenall189.sh — the nine-UVM-row-mode census.  MEASUREMENT
# ONLY; the official `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden.
#   CT189=<ct189assoc> cenall189.sh <pristine wd> <patched wd> <outdir> <TEST>...
# For every named test x mode it censuses GOLDEN, PRISTINE and PATCHED and
# scores the two columns with score189.py.  The GOLDEN path is read out of the
# row's own cmds.txt so no golden is guessed, and every row is asserted
# PROCESSED so a silent skip cannot read as "clean".
set -u
PW=$1; AW=$2; OUT=$3; shift 3
CEN=${CT189:?set CT189 to the built ct189assoc}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
LISTED=0; PROCESSED=0; SKIP=0
for t in "$@"; do
  for m in default testflags; do
    d=$(find "$PW/$m" -maxdepth 1 -name "$t-*" 2>/dev/null | head -1)
    a=$(find "$AW/$m" -maxdepth 1 -name "$t-*" 2>/dev/null | head -1)
    LISTED=$((LISTED+1))
    if [ -z "$d" ] || [ -z "$a" ] || [ ! -s "$d/slang.uhdm" ] || [ ! -s "$a/slang.uhdm" ]; then
      SKIP=$((SKIP+1)); echo "SKIP-NOFILE $t $m"; continue
    fi
    g=$(sed -n 's#.*golden cache hit \(/[^)]*\))#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$g" ] && g="$g/golden.uhdm"
    if [ -z "$g" ] || [ ! -s "$g" ]; then SKIP=$((SKIP+1)); echo "SKIP-NOGOLDEN $t $m"; continue; fi
    "$CEN" cen "$g"            > "$OUT/$t.$m.g.txt" 2>/dev/null </dev/null
    "$CEN" cen "$d/slang.uhdm" > "$OUT/$t.$m.a.txt" 2>/dev/null </dev/null
    "$CEN" cen "$a/slang.uhdm" > "$OUT/$t.$m.b.txt" 2>/dev/null </dev/null
    PROCESSED=$((PROCESSED+1))
    echo "==== $t $m"
    python3 "$HERE/score189.py" "$OUT/$t.$m.g.txt" "$OUT/$t.$m.a.txt" "$OUT/$t.$m.b.txt"
  done
done
echo "LISTED=$LISTED PROCESSED=$PROCESSED SKIPPED=$SKIP"
[ "$LISTED" = "$((PROCESSED+SKIP))" ] && echo "PROCESSED-ASSERT-OK" || { echo "PROCESSED-ASSERT-FAIL"; exit 1; }
