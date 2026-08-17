#!/usr/bin/env bash
# Detect pristine-right -> patched-wrong at DUMP-LINE multiset granularity.
# LOST  = lines golden HAS and pristine matched but patched no longer supplies
#         (min(g,pris) - min(g,pat) > 0)
# GAINEDBAD = lines patched supplies BEYOND golden's count that pristine did not
#         (max(pat-g,0) - max(pris-g,0) > 0)
set -u
D=${1:?dir}
cd "$D" || exit 9
python3 - <<'PY'
import collections,sys,os
def mс(f):
    c=collections.Counter()
    for l in open(f, errors='replace'):
        c[l.rstrip('\n').strip()]+=1
    return c
g=mс('g.dump'); p=mс('pris.dump'); q=mс('pat.dump')
lost=0; gained=0
lostl=[]; gainedl=[]
for k in set(g)|set(p)|set(q):
    a=min(g[k],p[k]); b=min(g[k],q[k])
    if a>b: lost+=a-b; lostl.append((a-b,k))
    x=max(p[k]-g[k],0); y=max(q[k]-g[k],0)
    if y>x: gained+=y-x; gainedl.append((y-x,k))
print("LOST=%d GAINEDBAD=%d  (%s)"%(lost,gained,os.path.basename(os.getcwd())))
for n,k in sorted(lostl,reverse=True)[:12]: print("   LOST x%d: %s"%(n,k[:150]))
for n,k in sorted(gainedl,reverse=True)[:12]: print("   GAIN x%d: %s"%(n,k[:150]))
PY
