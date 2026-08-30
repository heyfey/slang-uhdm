#!/bin/bash
# r10uvm166 — THE A-PRIORI MOVER PREDICTION, made from the PRISTINE databases
# ONLY (golden + our pristine), before any patched database exists.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS/G is ALWAYS golden.
#
# Descended from r10uvm155repro/predsweep155.sh.  For every row of a
# verify_golden workdir it censuses BOTH sides with ct166cen and keeps the cells
# in the ONLY bucket § arrayTdOfTypeParamDeclIsRefVar166 can move:
#   TOWARD  golden `ref_var` bound to an `array_typespec`, ours something else
#   AWAY    ours `ref_var` bound to an `array_typespec`, golden something else
# Both directions are printed so a mint in the wrong place cannot hide.
#
#   usage: CEN=<ct166cen> JOIN=<join166.py> predsweep166.sh <workdir> <out.tsv>
#
# GUARDS: a row with no golden or no slang.uhdm prints SKIP-NOFILE and is
# COUNTED; scratch is keyed on the row's RELATIVE path (mode/dir), because two
# rows in different modes share a name; the scratch is removed at the end so the
# sweep cannot fill /tmp.
set -u
CEN=${CEN:?ct166cen}
JOIN=${JOIN:?join166.py}
WD=${1:?workdir}; OUT=${2:?out.tsv}
: > "$OUT"
T=$(mktemp -d /tmp/r10uvm166_pred_XXXXXX) || exit 1
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
  python3 "$JOIN" "$T/g.tsv" "$T/o.tsv" --only-diff --set --cols VK,TSK,TSN \
    | grep '^DIFF' \
    | grep -E "G=\[\('ref_var', 'array_typespec'|O=\[\('ref_var', 'array_typespec'" \
    | sed "s#^#$rel\t#" >> "$OUT"
  n=$((n+1))
done
rm -rf "$T"
echo "-- rows=$n SKIP-NOFILE=$miss cells=$(grep -c '^[^-]' "$OUT" || true)"
