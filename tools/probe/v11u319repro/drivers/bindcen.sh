#!/bin/bash
# v11u319 bindcen.sh <S> <ptag> <ltag> <rel>...: the binding census. bindcls on golden, <ptag> and <ltag> under
# <S>/g/<rel> (case.sh's layout); a binding is AWAY when golden equals <ptag> and <ltag> differs, TOWARD when <ltag>
# now equals golden. Keyed by line:col name and occurrence. Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] && [ -x "$B/bindcls" ] || { echo "bindcen: source drivers/env.sh, build \$B/bindcls" >&2; exit 2; }
SS=$1; pt=$2; ft=$3; shift 3
for rel in "$@"; do
  for n in $FENCED; do echo "$rel" | grep -qw "$n" && { echo "bindcen: fenced refused" >&2; exit 2; }; done
  w=$SS/g/$rel; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1)
  [ -s "$g" ] && [ -s $w/$pt.uhdm ] && [ -s $w/$ft.uhdm ] || { echo "$rel MISSING"; continue; }
  python3 - "$rel" <($B/bindcls $g) <($B/bindcls $w/$pt.uhdm) <($B/bindcls $w/$ft.uhdm) <<'PY'
import sys
from collections import Counter
def rd(f):
    d={}; c=Counter()
    for l in open(f):
        a=l.split(' ',2); k=(a[0],a[1]); d[(k,c[k])]=a[2].strip(); c[k]+=1
    return d
G,P,F=rd(sys.argv[2]),rd(sys.argv[3]),rd(sys.argv[4])
aw=tw=0; det=[]
for k in set(G)|set(P)|set(F):
    g,p,f=G.get(k),P.get(k),F.get(k)
    if p==f: continue
    if g==p: aw+=1; det.append('%s:%s %s->%s'%(k[0][0],k[0][1],p,f))
    elif g==f: tw+=1
print(sys.argv[1],'away=%d toward=%d'%(aw,tw),' '.join(det))
PY
done
