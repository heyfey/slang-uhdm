#!/usr/bin/env bash
# v99 VERIFIER three-way arm scorer (independent).  golden=LHS.
#   PAT=<bin> PRI=<bin> MODE=def|elab ./vthree99.sh <arm.sv>
set -u
SRC=${1:?arm}; PAT=${PAT:?}; PRI=${PRI:?}; MODE=${MODE:-def}
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
REL=$(echo "$SRC" | sed 's|^\./||; s|/|__|g')
KEY=${REL%.*}_$MODE
D=${ARMWD:-/tmp/v99_armwd}/$KEY
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
BASE=$(basename "$SRC")
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
  "$DUMP" $tag.uhdm > $tag.dump 2>/dev/null
  python3 "$HERE/vcen99.py" $tag.dump > $tag.cen 2>/dev/null
done
"$DUMP" slpp_all/surelog.uhdm > g.dump 2>/dev/null
python3 "$HERE/vcen99.py" g.dump > g.cen 2>/dev/null
echo "$line"
python3 - "$KEY" <<'PY'
import sys, collections
key=sys.argv[1]
def load(p):
    d=collections.defaultdict(list)
    try: f=open(p)
    except OSError: return d
    for l in f:
        c=l.rstrip('\n').split('\t')
        if len(c)!=3: continue
        d[(c[0],c[1])].append(c[2])
    return d
G,P,Q=load('g.cen'),load('pris.cen'),load('pat.cen')
for scoring in ('MULTISET','SET'):
    norm=(lambda x: sorted(x)) if scoring=='MULTISET' else (lambda x: sorted(set(x)))
    tot=collections.Counter(); lines=[]
    for k in sorted(set(G)|set(P)|set(Q)):
        g,p,q=norm(G.get(k,[])),norm(P.get(k,[])),norm(Q.get(k,[]))
        if p==g and q==g: v='ALREADY-OK'
        elif p!=g and q==g: v='FIXED'
        elif p==g and q!=g: v='BROKE'
        else: v='STILL'
        tot[v]+=1
        if v!='ALREADY-OK':
            lines.append('  %-11s %s\n      G=%s\n      P=%s\n      Q=%s'%(v,k,g,p,q))
    print('  %-30s [%-8s] CELLS %3d  ALREADY-OK %3d  FIXED %3d  BROKE %3d  STILL %3d'%(
        key,scoring,sum(tot.values()),tot['ALREADY-OK'],tot['FIXED'],tot['BROKE'],tot['STILL']))
    if scoring=='SET':
        for l in lines: print(l)
PY
