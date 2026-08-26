#!/bin/bash
# r10uvm160 — THE A-PRIORI MOVER PREDICTION, made from the PRISTINE databases
# ONLY (golden + our pristine), before any patched database exists.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.  G is ALWAYS golden.
#
# For every row of a verify_golden workdir it censuses BOTH sides with ct160cen
# and runs predjoin160.py, which prints every OPERATION / ASSIGNMENT Rhs / call
# ARGUMENT list / CONDITION / hier_path element list whose golden side is
# PRESENT and ours ABSENT or TRUNCATED, plus the mirror buckets that must stay
# empty.
#
#   usage: CEN=<ct160cen> JOIN=<predjoin160.py> predsweep160.sh <workdir> <out.tsv>
#
# GUARDS (each an ops trap this campaign has paid for): a row with no golden or
# no slang.uhdm prints SKIP-NOFILE and is COUNTED (a sweep that reaches nothing
# must never read as perfection); scratch is keyed on the row's RELATIVE path,
# because two rows in different modes share a name; the scratch dir is this
# sweep's OWN mktemp and is removed at the end.
set -u
CEN=${CEN:?ct160cen}
JOIN=${JOIN:?predjoin160.py}
WD=${1:?workdir}; OUT=${2:?out.tsv}
: > "$OUT"
T=$(mktemp -d /tmp/r10uvm160_pred_XXXXXX) || exit 1
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
echo "-- rows=$n SKIP-NOFILE=$miss"
for b in PRED-TOWARD PRED-AWAY PRED-TRUNC PRED-GROW ONLYG ONLYO; do
  printf '%-12s %s\n' "$b" "$(grep -c "	$b-" "$OUT" || true)"
done
