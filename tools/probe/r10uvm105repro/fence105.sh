#!/usr/bin/env bash
# r10uvm105repro/fence105.sh — THE FENCE, written from PRISTINE databases only.
# MEASUREMENT ONLY; the official uhdm-cmp and scripts/verify_golden.py are the
# judges.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   fence105.sh <verify_golden workdir> <cen binary> <out.tsv>
#
# For EVERY test directory in the workdir it censuses BOTH sides and prints one
# row per site where golden holds an `unsupported_typespec` on a SUBROUTINE-BODY
# LOCAL and we do not.  Rows are split into two families by the census's own
# `TP` lines (every class TYPE PARAMETER name in the database):
#   HIT   the placeholder's name IS a class type parameter -> exactly the sites
#         § oobClassTypeParamLocalUnsupported105 moves.  A database with none of
#         these MUST NOT move; one with them MUST.
#   OTHER the same shape for a name that is NOT a type parameter (`process`,
#         `uvm_reg_field_cb_iter`, `sva_info`, ...) -- a DIFFERENT family, left
#         untouched by this pass and reported so the fence cannot be mistaken
#         for it.
#
# GUARDS: uhdm-cmp/`cen` exit 0 on a MISSING input, so both sides are
# existence-checked and a missing side is printed as SKIP and COUNTED; the golden
# path is read out of the test's own cmds.txt and the cache DIRECTORY is turned
# into .../golden.uhdm; every cell records its own rc.
set -u
WD=${1:?workdir}; CEN=${2:?cen binary}; OUT=${3:?out tsv}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no cen at $CEN"; exit 3; }
T=$(mktemp -d /tmp/r10uvm105_fence.XXXXXX)
: > "$OUT"
n=0; skip=0; hit=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  O=$d/slang.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo -e "SKIP\t$mode\t$test" >> "$OUT"; skip=$((skip+1)); continue
  fi
  "$CEN" "$G" G > "$T/g.tsv" 2>/dev/null; rg=$?
  "$CEN" "$O" O > "$T/o.tsv" 2>/dev/null; ro=$?
  if [ $rg -ne 0 ] || [ $ro -ne 0 ]; then
    echo -e "CENFAIL\t$mode\t$test\trc=$rg/$ro" >> "$OUT"; skip=$((skip+1)); continue
  fi
  python3 - "$T/g.tsv" "$T/o.tsv" "$mode" "$test" >> "$OUT" <<'PY'
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 12: continue
        d[tuple(f[1:7])][(f[8], f[9], f[10], f[7])] += 1
    return d
G = load(sys.argv[1]); O = load(sys.argv[2]); mode, test = sys.argv[3], sys.argv[4]
tps = set()
for pth in (sys.argv[1], sys.argv[2]):
    for ln in open(pth):
        f = ln.rstrip('\n').split('\t')
        if len(f) > 3 and f[1] == 'TP': tps.add(f[3])
UNS = 'unsupported_typespec'
seen = collections.Counter()
for k, gc in G.items():
    if k[0] != 'LOCAL': continue
    oc = O.get(k, collections.Counter())
    inter = gc & oc
    byname = collections.defaultdict(list)
    for v, n in (oc - inter).items():
        for _ in range(n): byname[v[3]].append(v)
    for v, n in (gc - inter).items():
        if v[0] != UNS: continue
        for _ in range(n):
            o = byname[v[3]].pop(0) if byname[v[3]] else None
            if o is not None and o[0] != UNS:
                seen[(k[5], v[1], v[2])] += 1
for (lc, nm, inst), n in sorted(seen.items()):
    print("%s\t%s\t%s\t%s\t%s\t%s\tx%d" %
          ("HIT" if nm in tps else "OTHER", mode, test, lc, nm, inst, n))
PY
  if grep -q "^HIT	$mode	$test	" "$OUT" 2>/dev/null; then hit=$((hit+1)); fi
  n=$((n+1))
done
rm -rf "$T"
echo "-- measured=$n SKIP=$skip"
echo "-- OTHER-family sites (NOT this law's): $(grep -c '^OTHER' "$OUT" || true) in $(awk -F'\t' '$1=="OTHER"{print $2"/"$3}' "$OUT" | sort -u | wc -l) databases"
echo "-- databases with at least one movable site: $(awk -F'\t' '$1=="HIT"{print $2"/"$3}' "$OUT" | sort -u | wc -l)"
awk -F'\t' '$1=="HIT"{print $2"/"$3}' "$OUT" | sort -u
