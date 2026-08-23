#!/usr/bin/env bash
# r10uvm107repro/fence107.sh — THE FENCE, written from PRISTINE databases only.
# MEASUREMENT ONLY; the official uhdm-cmp and scripts/verify_golden.py are the
# judges.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   fence107.sh <verify_golden workdir> <cen binary> <out.tsv>
#
# For EVERY test directory in the workdir it censuses BOTH sides and prints one
# row per REFERENCE where
#   * golden's `ref_obj` carries a `logic_net` vpiActual,
#   * ours carries something else (or nothing), and
#   * the name is a `ref_var` LOCAL of a task/func in OUR OWN database, in the
#     SAME listing VIEW and the SAME owner ("RV" rows) --
# i.e. exactly the sites § oobRefVarLocalHoistNet107 can move.  A database with
# no HIT row MUST NOT move; one with HIT rows MUST.
#
# It also prints, as OTHER rows, the same golden-logic_net/ours-not sites whose
# name is NOT such a local: a DIFFERENT family (the `process`-typed local, the
# non-`ref_var` body local, the hier_path base), left untouched by this pass and
# reported so the fence cannot be mistaken for it.
#
# GUARDS: the census exits non-zero on a missing/corrupt input, so both sides
# are existence-checked and every cell records its own rc; a missing side is
# printed as SKIP and COUNTED; the golden path is read out of the test's own
# cmds.txt and the cache DIRECTORY is turned into .../golden.uhdm.
set -u
WD=${1:?workdir}; CEN=${2:?cen binary}; OUT=${3:?out tsv}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no cen at $CEN"; exit 3; }
T=$(mktemp -d /tmp/r10uvm107_fence.XXXXXX)
trap 'rm -rf "$T"' EXIT
: > "$OUT"
n=0; skip=0; hitdb=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  O=$d/slang.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo -e "SKIP\t$mode\t$test" >> "$OUT"; skip=$((skip+1)); continue
  fi
  n=$((n+1))
  "$CEN" "$G" G > "$T/g.tsv" 2>/dev/null; rg=$?
  "$CEN" "$O" O > "$T/o.tsv" 2>/dev/null; ro=$?
  if [ $rg -ne 0 ] || [ $ro -ne 0 ]; then
    echo -e "CENFAIL\t$mode\t$test\trc=$rg/$ro" >> "$OUT"; skip=$((skip+1)); continue
  fi
  python3 - "$T/g.tsv" "$T/o.tsv" "$mode" "$test" >> "$OUT" <<'PY'
import sys, collections
def load(p):
    refs = {}
    rv = set()
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) > 5 and f[1] == 'RV':
            # keyed on (VIEW, OWNER, NAME): the ELABPKG copy of an out-of-body
            # definition is RENAMED to its bare method name, so the OOB column
            # is IB there and cannot be the filter -- the RV row for the SAME
            # view and owner is.
            rv.add((f[2], f[4], f[5]))
        elif len(f) > 10 and f[1] == 'REF':
            refs.setdefault((f[2], f[3], f[4], f[5], f[6]), []).append((f[7], f[9]))
    return refs, rv
G, _grv = load(sys.argv[1])
O, orv = load(sys.argv[2])
mode, test = sys.argv[3], sys.argv[4]
for k in sorted(set(G) & set(O)):
    ga = sorted(x[0] for x in G[k]); oa = sorted(x[0] for x in O[k])
    if ga == oa: continue
    if 'logic_net' not in ga: continue
    fam = 'HIT' if (k[0], k[2], k[4]) in orv else 'OTHER'
    print('%s\t%s\t%s\t%s\t%s\t%s\t%s\tG=%s\tO=%s\tpar=%s' %
          (fam, mode, test, k[0], k[1], k[2], k[3] + ' ' + k[4],
           ','.join(ga), ','.join(oa), O[k][0][1]))
PY
done
h=$(grep -c '^HIT' "$OUT" || true)
o=$(grep -c '^OTHER' "$OUT" || true)
hitdb=$(awk -F'\t' '$1=="HIT"{print $2"/"$3}' "$OUT" | sort -u | wc -l)
echo "MEASURED=$n SKIP=$skip HIT=$h OTHER=$o HIT_DATABASES=$hitdb"
awk -F'\t' '$1=="HIT"{print $2"/"$3}' "$OUT" | sort -u | sed 's/^/  MUST-MOVE /'
