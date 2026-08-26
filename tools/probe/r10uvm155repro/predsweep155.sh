#!/bin/bash
# r10uvm155 — THE A-PRIORI MOVER PREDICTION, made from the PRISTINE databases
# ONLY (golden + our pristine), before any patched database exists.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS/G is ALWAYS golden.
#
# For every row of a verify_golden workdir it censuses BOTH sides with ct155cen
# and prints the cells where the DECLARATION KIND disagrees and EITHER side is a
# `ref_var` — the only bucket § blockLocalTdDeclIsRefVar155 can move, in either
# direction (TOWARD: golden ref_var, ours resolved; AWAY: the reverse).
#
#   usage: CEN=<ct155cen> JOIN=<join155.py> predsweep155.sh <workdir> <out.tsv>
#
# GUARDS: a row with no golden or no slang.uhdm prints SKIP-NOFILE and is
# COUNTED; scratch is keyed on the row's RELATIVE path (mode/dir), because two
# rows in different modes share a name; the scratch is removed per row so the
# sweep cannot fill /tmp.
set -u
CEN=${CEN:?ct155cen}
JOIN=${JOIN:?join155.py}
WD=${1:?workdir}; OUT=${2:?out.tsv}
: > "$OUT"
T=$(mktemp -d /tmp/r10uvm155_pred_XXXXXX) || exit 1
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
  python3 "$JOIN" "$T/g.tsv" "$T/o.tsv" --only-diff --set --cols VK,TSK,TSN \
    | grep '^DIFF' | grep 'ref_var' | sed "s#^#$rel\t#" >> "$OUT"
  n=$((n+1))
done
rm -rf "$T"
echo "-- rows=$n SKIP-NOFILE=$miss cells=$(grep -c '^[^-]' "$OUT" || true)"
