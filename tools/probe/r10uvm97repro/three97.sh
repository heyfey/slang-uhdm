#!/usr/bin/env bash
# r10uvm97 THREE-WAY ARM SCORER — MEASUREMENT ONLY.  golden(Surelog) is LHS.
#   PAT= PRI= MODE=def|elab ./three97.sh <arm.sv>
# Builds the three databases, runs ct97cen (the class-nested typedef census) on
# each and joins on (SITE, OWNER, NAME, KIND) — never on the ID (ids differ per
# side and per run) and never on the SPAN (golden and we legitimately locate a
# shared typedef object at different declarations; no generated Compare reads a
# span).  Classifies every cell:
#   ALREADY-OK  pristine already equalled golden
#   FIXED       pristine differed, patched equals golden
#   BROKE       pristine equalled golden, patched does not      <- must be 0
#   STILL       both differ from golden
# Also reports the OFFICIAL uhdm-cmp verdict + head count for both binaries and
# each binary's rc (verify_golden.py records rc=139 as SLANG_REJECT, so a driver
# that does not print rc can hide a segfault).
set -u
SRC=${1:?arm}; PAT=${PAT:?}; PRI=${PRI:?}; MODE=${MODE:-def}
CEN=${CEN:-/tmp/r10uvm97_ct97cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
KEY=$(basename "$SRC" .sv)_$MODE
D=${ARMWD:-/tmp/r10uvm97_armwd}/$KEY
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
        # key   = SITE | OWNER | NAME | KIND       (never ID, never SPAN)
        # value = ALIAS-PRESENT | TARGET | INST    (the judged shape)
        d['|'.join((c[0], c[2], c[3], c[4]))].append(
            ('ALIAS' if c[6] != '-' else 'NOALIAS', c[7], c[8]))
    return d
G, P, Q = load('g.cen'), load('pris.cen'), load('pat.cen')
tot = collections.Counter()
lines = []
for k in sorted(set(G) | set(P) | set(Q)):
    g, p, q = sorted(G.get(k, [])), sorted(P.get(k, [])), sorted(Q.get(k, []))
    if p == g and q == g: v = 'ALREADY-OK'
    elif p != g and q == g: v = 'FIXED'
    elif p == g and q != g: v = 'BROKE'
    else: v = 'STILL'
    tot[v] += 1
    if v != 'ALREADY-OK':
        lines.append('  %-11s %s\n      G=%s\n      P=%s\n      Q=%s' % (v, k, g, p, q))
print('  %-22s CELLS %3d  ALREADY-OK %3d  FIXED %3d  BROKE %3d  STILL %3d' % (
    key, sum(tot.values()), tot['ALREADY-OK'], tot['FIXED'], tot['BROKE'], tot['STILL']))
for l in lines: print(l)
PY
