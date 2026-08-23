#!/usr/bin/env bash
# r10uvm107repro/pred107.sh — THE MOVER PREDICTOR, written from PRISTINE
# databases only (OUR side alone; no golden is read).  MEASUREMENT ONLY.
#
#   pred107.sh <verify_golden workdir> <cen binary> <out.tsv>
#
# § oobRefVarLocalHoistNet107 can only touch a reference that
#   * names a `ref_var` LOCAL of a task/func, in the SAME listing VIEW and the
#     SAME owner (the census's own RV rows), and
#   * currently carries NO vpiActual (§ refVarLocalWindowBinds5 refused it) or
#     carries the DECLARATION (the § 5 residue R1 cell this law completes).
# Every other reference is out of the predicate by construction.  So a database
# with no such row CANNOT move, and this is the UPPER BOUND on the mover set --
# checked against the byte movers the patched sweep actually produces.
#
# Rows are printed per database with the count and the distinct owners, so the
# prediction can be quoted BY NAME.
set -u
WD=${1:?workdir}; CEN=${2:?cen binary}; OUT=${3:?out tsv}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no cen at $CEN"; exit 3; }
T=$(mktemp -d /tmp/r10uvm107_pred.XXXXXX)
trap 'rm -rf "$T"' EXIT
: > "$OUT"
n=0; skip=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  O=$d/slang.uhdm
  [ -f "$O" ] || { echo -e "SKIP\t$mode\t$test" >> "$OUT"; skip=$((skip+1)); continue; }
  n=$((n+1))
  "$CEN" "$O" O > "$T/o.tsv" 2>/dev/null || { echo -e "CENFAIL\t$mode\t$test" >> "$OUT"; skip=$((skip+1)); continue; }
  python3 - "$T/o.tsv" "$mode" "$test" >> "$OUT" <<'PY'
import sys
rv=set(); rows=[]
for ln in open(sys.argv[1]):
    f=ln.rstrip('\n').split('\t')
    if len(f)>5 and f[1]=='RV': rv.add((f[2],f[4],f[5]))
    elif len(f)>10 and f[1]=='REF': rows.append(f)
mode,test=sys.argv[2],sys.argv[3]
# The law can only reach a reference the NamedValue+netMap path built: a
# hier_path ELEMENT and a method-call PREFIX are made by other arms and never
# see it (arm a1 cells oob_ret 104:12 and oob_recvcall 99:11, both golden NONE
# and both unmoved).  And the owner must be an OUT-OF-BODY definition, which
# only the DEFPKG listing spells (the ELABPKG copy is renamed to the bare
# method name).
oob = {(f[4], f[6]) for f in rows if f[3] == 'OOB'}
hits = [f for f in rows
        if (f[2], f[4], f[6]) in rv and f[7] in ('NONE', 'ref_var')
        and f[9] != 'hier_path' and (f[4], f[6]) in oob]
if hits:
    owners=sorted({f[4] for f in hits})
    print('CAND\t%s\t%s\t%d\t%s' % (mode,test,len(hits),','.join(owners[:6])))
PY
done
c=$(grep -c '^CAND' "$OUT" || true)
echo "MEASURED=$n SKIP=$skip CANDIDATE_DATABASES=$c"
awk -F'\t' '$1=="CAND"{print "  MAY-MOVE "$2"/"$3"  sites="$4}' "$OUT"
