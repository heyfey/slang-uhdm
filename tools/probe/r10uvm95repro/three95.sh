#!/usr/bin/env bash
# r10uvm95 THREE-WAY ARM SCORER — MEASUREMENT ONLY.  golden(Surelog) is LHS.
#   PAT= PRI= MODE=def|elab ./three95.sh <arm.sv>
# Builds the three databases, runs ct95cen (the type-query census) on each and
# joins on the SPAN, classifying every candidate cell:
#   ALREADY-OK  pristine already equalled golden
#   FIXED       pristine differed, patched equals golden
#   BROKE       pristine equalled golden, patched does not      <- must be 0
#   STILL       both differ from golden
# Also reports the OFFICIAL uhdm-cmp verdict + head count for both binaries.
set -u
SRC=${1:?arm}; PAT=${PAT:?}; PRI=${PRI:?}; MODE=${MODE:-def}
CEN=${CEN:-/tmp/r10uvm95_ct95cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
KEY=$(basename "$SRC" .sv)_$MODE
D=/tmp/r10uvm95_armwd/$KEY
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
SLFLAG=""; OURFLAG=""
if [ "$MODE" = elab ]; then SLFLAG="-elabuhdm"; OURFLAG="-elabuhdm"; fi
"$SURELOG" -parse -nocache $SLFLAG "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "$KEY SURELOG_FAIL"; exit 5; }
line="$KEY:"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" $OURFLAG "$LEAF" -o $tag.uhdm > $tag.log 2>&1; rc=$?
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
def load(p):
    d = collections.defaultdict(list)
    try: f = open(p)
    except OSError: return d
    for l in f:
        l = l.rstrip('\n')
        if not l: continue
        c = l.split('\t')
        if len(c) < 6: continue
        sp = c[0]; i = sp.find(':')
        d[sp[i+1:]].append((c[1], c[2], c[3], c[6] if len(c) > 6 else '?'))
    return d
G, P, Q = load('g.cen'), load('pris.cen'), load('pat.cen')
tot = collections.Counter()
for sp in sorted(set(G) | set(P) | set(Q)):
    g = sorted((x[0], x[1]) for x in G.get(sp, []))
    p = sorted((x[0], x[1]) for x in P.get(sp, []))
    q = sorted((x[0], x[1]) for x in Q.get(sp, []))
    full = G.get(sp, []) or P.get(sp, []) or Q.get(sp, [])
    hascall = any(x[0] == 'CALL' for x in G.get(sp, []) + P.get(sp, []) + Q.get(sp, []))
    hassrc = any(x[3] == 'SRC$' for x in G.get(sp, []) + P.get(sp, []) + Q.get(sp, []))
    if not hascall and not hassrc: continue
    if p == g and q == g: v = 'ALREADY-OK'
    elif p != g and q == g: v = 'FIXED'
    elif p == g and q != g: v = 'BROKE'
    else: v = 'STILL'
    tot[v] += 1
    if v != 'ALREADY-OK':
        print('   %-11s %-22s G=%-22s PRI=%-22s PAT=%s' % (
            v, sp,
            ';'.join('%s:%s' % x for x in g) or '<none>',
            ';'.join('%s:%s' % x for x in p) or '<none>',
            ';'.join('%s:%s' % x for x in q) or '<none>'))
print('   CELLS %d  ALREADY-OK %d  FIXED %d  BROKE %d  STILL %d' % (
    sum(tot.values()), tot['ALREADY-OK'], tot['FIXED'], tot['BROKE'], tot['STILL']))
PY
echo "WD=$D" >&2
