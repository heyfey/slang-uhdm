#!/usr/bin/env bash
# r10uvm214 — the ROW census.  MEASUREMENT ONLY; the official uhdm-cmp is the
# judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For each NAMED row-mode of a `verify_golden.py` workdir: run `ct214bind
# --keycount` on BOTH databases, join them as a MULTISET (cen214.py), and
# report
#   (a) the WHOLE typespec-copy census (context), and
#   (b) THE LAW'S OWN POPULATION — the copies whose HOLDER LISTING is a
#       package's DEF listing (`package[ALLPKG:<p>]<function|task:C::m<...`),
#       split into the cells that agree, the ONLY-GOLDEN cells and the
#       ONLY-OURS cells.
# The golden-vs-golden CALIBRATION is run FIRST on every row and printed.
#
# usage: TS=<ct214bind> CEN=<cen214.py> ./cen214.sh <workdir> <outdir> <name>...
#
# GUARDS: a missing side prints SKIP-NOFILE and is COUNTED (uhdm-cmp exits 0 on
# a missing input; a driver that reaches nothing must never read as perfection);
# the golden path is read out of the row's own cmds.txt and the cache DIRECTORY
# is turned into .../golden.uhdm; `grep -c` never sits in a `set -e` position.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
TS=${TS:?path to ct214bind}
CEN=${CEN:?path to cen214.py}
mkdir -p "$OUT" || exit 1
miss=0; done_=0
LAWRE='^package\[ALLPKG:[A-Za-z_0-9@]+\]<(function|task):[A-Za-z_0-9]+::'
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm
      G=""
      [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "ROW $n $mode SKIP-NOFILE(g=${G:-none})"
        miss=$((miss+1)); continue
      fi
      "$TS" --keycount "$G" . > "$OUT/$n.$mode.g.kc"
      "$TS" --keycount "$O" . > "$OUT/$n.$mode.o.kc"
      cal=$(python3 "$CEN" "$OUT/$n.$mode.g.kc" "$OUT/$n.$mode.g.kc" | tail -1)
      python3 "$CEN" "$OUT/$n.$mode.g.kc" "$OUT/$n.$mode.o.kc" > "$OUT/$n.$mode.cen"
      awk -F'\t' -v re="$LAWRE" '$4 ~ re' "$OUT/$n.$mode.g.kc" > "$OUT/$n.$mode.g.law"
      awk -F'\t' -v re="$LAWRE" '$4 ~ re' "$OUT/$n.$mode.o.kc" > "$OUT/$n.$mode.o.law"
      python3 "$CEN" "$OUT/$n.$mode.g.law" "$OUT/$n.$mode.o.law" > "$OUT/$n.$mode.law.cen"
      echo "ROW $n $mode CALIB[$cal]"
      echo "ROW $n $mode ALL   $(tail -1 "$OUT/$n.$mode.cen")"
      echo "ROW $n $mode DEFLST $(tail -1 "$OUT/$n.$mode.law.cen")"
      done_=$((done_+1))
    done
  done
done
echo "-- rows measured=$done_ SKIP-NOFILE=$miss"
