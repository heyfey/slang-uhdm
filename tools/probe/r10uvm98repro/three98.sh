#!/usr/bin/env bash
# r10uvm98 — MEASUREMENT ONLY.  Three-way arm scorer: golden(Surelog)=LHS,
# pristine, patched.  rc recorded for every cell.  Runs one arm in one view.
#   PAT=<bin> PRI=<bin> MODE=def|elab ./three98.sh <arm.sv|arm.v>
set -u
SRC=${1:?arm}; PAT=${PAT:?}; PRI=${PRI:?}; MODE=${MODE:-def}
CEN=${CEN:-/tmp/r10uvm98_ct98cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
export CEN98_ALL=1
BASE=$(basename "$SRC"); KEY=${BASE%.*}_$MODE
D=${ARMWD:-/tmp/r10uvm98_armwd3}/$KEY
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
cd "$D" || exit 9
SLFLAG=""; OURFLAG=""
if [ "$MODE" = elab ]; then SLFLAG="-elabuhdm"; OURFLAG="-elabuhdm"; fi
"$SURELOG" -parse -nocache $SLFLAG "$BASE" >surelog.log 2>&1 </dev/null
if [ ! -f slpp_all/surelog.uhdm ]; then echo "$KEY SURELOG_FAIL"; exit 5; fi
line="$KEY:"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" $OURFLAG "$BASE" -o $tag.uhdm > $tag.log 2>&1 </dev/null; rc=$?
  if [ ! -f $tag.uhdm ]; then line="$line $tag=NO_OUTPUT(rc=$rc)"; continue; fi
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  line="$line $tag=rc$rc/$res/heads$(grep -c '^LHS:' $tag.cmp; true)/lines$(wc -l < $tag.cmp)"
done
"$CEN" slpp_all/surelog.uhdm > g.cen 2>/dev/null
"$CEN" pris.uhdm > pris.cen 2>/dev/null
"$CEN" pat.uhdm  > pat.cen  2>/dev/null
echo "$line"
python3 - "$KEY" <<'PY'
import sys, collections
key = sys.argv[1]
SKIP = ('work@mailbox', 'work@process', 'work@semaphore')
def load(p):
    d = collections.defaultdict(list)
    try: f = open(p)
    except OSError: return d
    for l in f:
        c = l.rstrip('\n').split('\t')
        if len(c) != 6: continue
        if any(c[1].startswith(s) for s in SKIP): continue
        v = (c[2], c[3], c[4], c[5])
        # FIELD=DEFN scores the ONE field this pass moves — `Class_defn`, the
        # LAST field of class_typespec::Compare and the head's field.  The other
        # three (VpiName, Typedef_alias, Instance) are pre-existing families
        # (R2/R3) that must not drown the signal; FIELD=ALL is the default and
        # scores the whole judged value.
        import os as _o
        f = _o.environ.get('FIELD', 'ALL')
        if f != 'ALL':
            v = v[{'TSNAME': 0, 'DEFN': 1, 'ALIAS': 2, 'INST': 3}[f]]
        d[(c[0], c[1])].append(v)
    return d
G, P, Q = load('g.cen'), load('pris.cen'), load('pat.cen')
tot = collections.Counter(); lines = []
for k in sorted(set(G) | set(P) | set(Q)):
    g, p, q = sorted(G.get(k, [])), sorted(P.get(k, [])), sorted(Q.get(k, []))
    if p == g and q == g: v = 'ALREADY-OK'
    elif p != g and q == g: v = 'FIXED'
    elif p == g and q != g: v = 'BROKE'
    else: v = 'STILL'
    tot[v] += 1
    if v != 'ALREADY-OK':
        lines.append('  %-11s %s\n      G=%s\n      P=%s\n      Q=%s' % (v, k, g, p, q))
import os as _o2
print('  %-28s [%s] CELLS %3d  ALREADY-OK %3d  FIXED %3d  BROKE %3d  STILL %3d' % (
    key, _o2.environ.get('FIELD', 'ALL'), sum(tot.values()), tot['ALREADY-OK'], tot['FIXED'], tot['BROKE'], tot['STILL']))
for l in lines: print(l)
PY
