#!/bin/bash
# r10uvm157 — THE A-PRIORI MOVER PREDICTION and the CORPUS POPULATION CENSUS,
# made from the PRISTINE databases ONLY (golden + our pristine), before any
# patched database exists.  MEASUREMENT ONLY; the official uhdm-cmp is the
# judge.  LHS/G is ALWAYS golden (Surelog).
#
# For every row of a verify_golden workdir it censuses BOTH sides with ct157cen
# and prints every STATEMENT-SCOPE cell whose typespec LISTING disagrees —
# both directions, both columns:
#     ONLY-G / ONLY-O   the scope itself exists on one side only
#     DIFF              the listing count or a listed entry disagrees
# and a per-row trailer with the two counts.
#
#   usage: CEN=<ct157cen> SCORE=<score157.py> predsweep157.sh <workdir> <out.tsv>
#
# GUARDS: a row with no golden or no slang.uhdm prints SKIP-NOFILE and is
# COUNTED; scratch is keyed on the row's RELATIVE path (mode/dir), because two
# rows in different modes share a name; the scratch is removed at the end so
# the sweep cannot fill /tmp.
set -u
CEN=${CEN:?ct157cen}
SCORE=${SCORE:?score157.py}
WD=${1:?workdir}; OUT=${2:?out.tsv}
: > "$OUT"
T=$(mktemp -d /tmp/r10uvm157_pred_XXXXXX) || exit 1
n=0; miss=0
for d in "$WD"/*/*/; do
  rel=${d#"$WD"/}
  [ -f "$d/slang.uhdm" ] || { echo -e "SKIP-NOFILE\t$rel\tno-slang.uhdm" >> "$OUT"; miss=$((miss+1)); continue; }
  G=""
  [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    echo -e "SKIP-NOFILE\t$rel\tno-golden" >> "$OUT"; miss=$((miss+1)); continue
  fi
  "$CEN" "$G" G > "$T/g.tsv" 2>/dev/null
  "$CEN" "$d/slang.uhdm" O > "$T/o.tsv" 2>/dev/null
  python3 "$SCORE" "$T/g.tsv" "$T/o.tsv" | grep -E '^(DIFF|ONLY-G|ONLY-O|     [GO]=|-- )' \
    | sed "s#^#$rel\t#" >> "$OUT"
  n=$((n+1))
done
rm -rf "$T"
echo "-- rows=$n SKIP-NOFILE=$miss"
