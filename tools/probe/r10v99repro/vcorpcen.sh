#!/usr/bin/env bash
# v99 verifier corpus census: golden vs pristine vs patched on ONE database dir.
set -u
REL=$1; PATWD=$2; PRISWD=$3
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
G=$(grep -o '/home/[^ )]*slang-uhdm-goldens/[a-f0-9]*' "$PATWD/$REL/cmds.txt" | head -1)/golden.uhdm
[ -f "$G" ] || { echo "$REL NO_GOLDEN($G)"; exit 3; }
O=/tmp/v99_corpcen/$(echo "$REL" | tr '/' '_'); mkdir -p "$O"
"$DUMP" "$G" 2>/dev/null > "$O/g.dump"
"$DUMP" "$PRISWD/$REL/slang.uhdm" 2>/dev/null > "$O/pris.dump"
"$DUMP" "$PATWD/$REL/slang.uhdm"  2>/dev/null > "$O/pat.dump"
for t in g pris pat; do python3 /tmp/v99_arms/vcen99.py "$O/$t.dump" > "$O/$t.cen"; done
python3 - "$REL" "$O" <<'PY'
import sys, collections
rel, O = sys.argv[1], sys.argv[2]
def load(p):
    d=collections.defaultdict(list)
    for l in open(p):
        c=l.rstrip('\n').split('\t')
        if len(c)!=3: continue
        d[(c[0],c[1])].append(c[2])
    return d
G,P,Q=load(O+'/g.cen'),load(O+'/pris.cen'),load(O+'/pat.cen')
for sc in ('MULTISET','SET'):
    nrm=(lambda x: sorted(x)) if sc=='MULTISET' else (lambda x: sorted(set(x)))
    t=collections.Counter(); det=[]
    for k in sorted(set(G)|set(P)|set(Q)):
        g,p,q=nrm(G.get(k,[])),nrm(P.get(k,[])),nrm(Q.get(k,[]))
        if p==g and q==g: v='ALREADY-OK'
        elif p!=g and q==g: v='TO-GOLDEN'
        elif p==g and q!=g: v='AWAY-GOLDEN'
        else: v='STILL'
        t[v]+=1
        if v in ('TO-GOLDEN','AWAY-GOLDEN'): det.append('    %s %s'%(v,k))
    print('  %-34s [%-8s] cells %4d  ALREADY-OK %4d  TO-GOLDEN %3d  AWAY-GOLDEN %3d  STILL %3d'%(
        rel,sc,sum(t.values()),t['ALREADY-OK'],t['TO-GOLDEN'],t['AWAY-GOLDEN'],t['STILL']))
    if sc=='SET':
        for x in det: print(x)
PY
