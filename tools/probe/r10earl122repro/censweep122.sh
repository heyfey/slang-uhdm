#!/usr/bin/env bash
# r10earl122 — run cen122 (and pred122) over a WHOLE `verify_golden.py` workdir:
# both halves of every row, the golden path taken from each test's OWN cmds.txt.
#
# MEASUREMENT ONLY.  `uhdm-cmp` / `scripts/verify_golden.py` are the judges.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# Every rc is logged; a missing database is a row, not a silent skip.
#
# usage: CEN=<cen122> [PRED=<pred122>] bash censweep122.sh <workdir> <outprefix>
set -u
CEN=${CEN:-/tmp/r10earl122_cen122}
PRED=${PRED:-}
WD=${1:?workdir}; OUT=${2:?outprefix}
: > "$OUT.cells"; : > "$OUT.rc"; : > "$OUT.pred"
for cm in $(find "$WD" -name cmds.txt | sort); do
  d=$(dirname "$cm")
  mode=$(basename "$(dirname "$d")")
  test=$(basename "$d"); test=${test%-*}
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$cm" | head -1)
  [ -n "$g" ] && g="$g/golden.uhdm"
  o="$d/slang.uhdm"
  if [ -n "$g" ] && [ -f "$g" ]; then
    "$CEN" "$g" 2>/dev/null | grep '^CELL' | sed "s#^CELL\t#G\t$test\t$mode\t#" >> "$OUT.cells"
    echo "G $test $mode $?" >> "$OUT.rc"
  else
    echo "G $test $mode NO-GOLDEN" >> "$OUT.rc"
  fi
  if [ -f "$o" ]; then
    "$CEN" "$o" 2>/dev/null | grep '^CELL' | sed "s#^CELL\t#O\t$test\t$mode\t#" >> "$OUT.cells"
    echo "O $test $mode $?" >> "$OUT.rc"
    if [ -n "$PRED" ]; then
      "$PRED" "$o" 2>/dev/null | sed "s#^PRED\t#P\t$test\t$mode\t#" >> "$OUT.pred"
    fi
  else
    echo "O $test $mode NO-DB" >> "$OUT.rc"
  fi
done
wc -l "$OUT.cells" "$OUT.rc" "$OUT.pred"
