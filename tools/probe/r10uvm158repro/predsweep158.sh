#!/bin/bash
# r10uvm158 — THE A-PRIORI MOVER PREDICTION, made from the PRISTINE databases
# ONLY (golden + our pristine), before any patched database exists.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS/G is ALWAYS golden.
#
# For every row of a verify_golden workdir it censuses BOTH sides with ct158cen
# and prints every statement block where GOLDEN LISTS VARIABLES and OUR
# PRISTINE DATABASE HAS NO vpiVariables VECTOR AT ALL — the null-vector head
# section badBlockKeepsItsScope158 clears.  The reverse bucket is printed too
# and must stay empty.
#
#   usage: CEN=<ct158cen> JOIN=<predjoin158.py> predsweep158.sh <workdir> <out.tsv>
#
# GUARDS (each an ops trap this campaign has paid for): a row with no golden or
# no slang.uhdm prints SKIP-NOFILE and is COUNTED (a sweep that reaches nothing
# must never read as perfection); scratch is keyed on the row's RELATIVE path,
# because two rows in different modes share a name; the scratch is removed at
# the end so the sweep cannot fill /tmp.
set -u
CEN=${CEN:?ct158cen}
JOIN=${JOIN:?predjoin158.py}
WD=${1:?workdir}; OUT=${2:?out.tsv}
: > "$OUT"
T=$(mktemp -d /tmp/r10uvm158_pred_XXXXXX) || exit 1
n=0; miss=0
for d in "$WD"/*/*/; do
  rel=${d#"$WD"/}
  [ -f "$d/slang.uhdm" ] || { printf 'SKIP-NOFILE\t%s\tno-slang.uhdm\n' "$rel" >> "$OUT"; miss=$((miss+1)); continue; }
  G=""
  [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    printf 'SKIP-NOFILE\t%s\tno-golden\n' "$rel" >> "$OUT"; miss=$((miss+1)); continue
  fi
  "$CEN" "$G" G > "$T/g.tsv" 2>/dev/null
  "$CEN" "$d/slang.uhdm" O > "$T/o.tsv" 2>/dev/null
  python3 "$JOIN" "$T/g.tsv" "$T/o.tsv" | sed "s#^#$rel\t#" >> "$OUT"
  n=$((n+1))
done
rm -rf "$T"
echo "-- rows=$n SKIP-NOFILE=$miss toward=$(grep -c 'PRED-TOWARD' "$OUT" || true) away=$(grep -c 'PRED-AWAY' "$OUT" || true)"
