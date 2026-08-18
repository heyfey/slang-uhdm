#!/usr/bin/env bash
# v97 verifier three-way arm runner. golden(Surelog)=LHS.
#   PAT= PRI= MODE=def|elab /tmp/v97_armrun.sh <arm.sv>
set -u
SRC=${1:?arm}; PAT=${PAT:?}; PRI=${PRI:?}; MODE=${MODE:-def}
CEN=${CEN:-/tmp/v97_ct97cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
KEY=$(basename "$SRC" .sv)_$MODE
D=${ARMWD:-/tmp/v97_armwd}/$KEY
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
SLFLAG=""; OURFLAG=""
if [ "$MODE" = elab ]; then SLFLAG="-elabuhdm"; OURFLAG="-elabuhdm"; fi
"$SURELOG" -parse -nocache $SLFLAG "$LEAF" >surelog.log 2>&1 </dev/null
if [ ! -f slpp_all/surelog.uhdm ]; then echo "$KEY SURELOG_FAIL"; exit 5; fi
line="$KEY:"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" $OURFLAG "$LEAF" -o $tag.uhdm > $tag.log 2>&1 </dev/null; rc=$?
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
        # VIEW-GENERAL, SPAN-free, file-free, SRCTEXT-free key.
        # value keeps the alias TARGET identity (kind+name of the actual),
        # not just a boolean, plus Class_defn target and Instance.
        al = c[6]
        if al != '-':
            # strip the trailing @span from `<ref>-><kind>(<name>)@<span>`
            al = al.rsplit('@', 1)[0]
        d['|'.join((c[0], c[2], c[3], c[4]))].append((al, c[7], c[8]))
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
print('  %-26s CELLS %3d  ALREADY-OK %3d  FIXED %3d  BROKE %3d  STILL %3d' % (
    key, sum(tot.values()), tot['ALREADY-OK'], tot['FIXED'], tot['BROKE'], tot['STILL']))
for l in lines: print(l)
PY
