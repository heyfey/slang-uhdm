#!/usr/bin/env bash
# r10uvm96 THREE-WAY ARM SCORER — MEASUREMENT ONLY.  golden(Surelog) is LHS.
#   PAT= PRI= MODE=def|elab ./three96.sh <arm.sv>
# Builds the three databases, runs ct96cen (the cast-target census) on each and
# joins on the cast OPERATION's SPAN, classifying every cast cell:
#   ALREADY-OK  pristine already equalled golden
#   FIXED       pristine differed, patched equals golden
#   BROKE       pristine equalled golden, patched does not      <- must be 0
#   STILL       both differ from golden
# Also reports the OFFICIAL uhdm-cmp verdict + head count for both binaries,
# and each binary's rc (verify_golden.py records rc=139 as SLANG_REJECT, so a
# driver that does not print rc can hide a segfault).
set -u
SRC=${1:?arm}; PAT=${PAT:?}; PRI=${PRI:?}; MODE=${MODE:-def}
CEN=${CEN:-/tmp/r10uvm96_ct96cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
KEY=$(basename "$SRC" .sv)_$MODE
D=${ARMWD:-/tmp/r10uvm96_armwd}/$KEY
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
        if len(c) < 9: continue
        d[c[0] + '|' + c[3]].append((c[1], c[4]))   # SPAN|SRCTEXT -> (kind, refname)
    return d
G, P, Q = load('g.cen'), load('pris.cen'), load('pat.cen')
tot = collections.Counter()
for sp in sorted(set(G) | set(P) | set(Q)):
    g, p, q = sorted(G.get(sp, [])), sorted(P.get(sp, [])), sorted(Q.get(sp, []))
    if p == g and q == g: v = 'ALREADY-OK'
    elif p != g and q == g: v = 'FIXED'
    elif p == g and q != g: v = 'BROKE'
    else: v = 'STILL'
    tot[v] += 1
    if v != 'ALREADY-OK':
        print('   %-11s %-34s G=%-22s PRI=%-22s PAT=%s' % (
            v, sp,
            ';'.join('%s' % x[0] for x in g) or '<none>',
            ';'.join('%s' % x[0] for x in p) or '<none>',
            ';'.join('%s' % x[0] for x in q) or '<none>'))
print('   CELLS %d  ALREADY-OK %d  FIXED %d  BROKE %d  STILL %d' % (
    sum(tot.values()), tot['ALREADY-OK'], tot['FIXED'], tot['BROKE'], tot['STILL']))
PY
echo "WD=$D" >&2
