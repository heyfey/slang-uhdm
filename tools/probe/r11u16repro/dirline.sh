#!/usr/bin/env bash
# Per-LINE directional census over a grid arm's normalized sorted dumps.
# ADDED lines (in patched, not pristine): GOOD if golden has >= as many.
# REMOVED lines (in pristine, not patched): GOOD if golden did NOT have them.
set -u
G=${G:-/tmp/v11u13_grid}
for d in "$@"; do
  cd "$G/$d" || continue
  for f in gold pris pat; do sed 's#/tmp/[^ ,)]*##g' $f.dump | sed 's/^ *//' | sort > /tmp/v11u13_dl_$f; done
  # multiset counts per line
  python3 - "$d" <<'PY'
import sys, collections
d=sys.argv[1]
def mc(p):
    c=collections.Counter()
    for l in open(p, errors='replace'): c[l.rstrip('\n')]+=1
    return c
g=mc('/tmp/v11u13_dl_gold'); p=mc('/tmp/v11u13_dl_pris'); q=mc('/tmp/v11u13_dl_pat')
keys=set(g)|set(p)|set(q)
to=away=neu=0; away_l=[]
for k in keys:
    gp=abs(g[k]-p[k]); gq=abs(g[k]-q[k])
    if gq<gp: to+=1
    elif gq>gp: away+=1; away_l.append((k,g[k],p[k],q[k]))
print("%s LINEKEYS TO-GOLDEN=%d AWAY-GOLDEN=%d"%(d,to,away))
for k,a,b,c in away_l[:12]: print("   AWAY g=%d pris=%d pat=%d | %s"%(a,b,c,k[:110]))
PY
done
