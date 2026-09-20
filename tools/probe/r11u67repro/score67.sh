#!/usr/bin/env bash
# r11u67 scorer: golden vs pristine vs law, per (view|scope|name|kind) MULTISET.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GRID=${GRID:-$HERE/grid}
for a in $(ls -d $GRID/g*/ | xargs -n1 basename | sort -V); do
  d=$GRID/$a
  [ -f $d/gold.pris.dump ] && [ -f $d/ours.pris.dump ] && [ -f $d/ours.law.dump ] || { echo "$a SKIP"; continue; }
  python3 - "$d" "$a" "$HERE" <<'PY'
import sys, subprocess, collections
d, a, HERE = sys.argv[1], sys.argv[2], sys.argv[3]
def rd(p):
    out = subprocess.run(['python3',HERE+'/../r11v65repro/nettype65.py',p],capture_output=True,text=True).stdout
    c = collections.Counter()
    for l in out.split('\n'):
        if not l: continue
        parts = l.rsplit('|NT=',1)
        c[(parts[0], int(parts[1]))] += 1
    return c
g, p, w = rd(d+'/gold.pris.dump'), rd(d+'/ours.pris.dump'), rd(d+'/ours.law.dump')
# group by key (without NT) -> sorted multiset of NT values
def by(c):
    m = collections.defaultdict(list)
    for (k,nt),n in c.items(): m[k] += [nt]*n
    return {k:sorted(v) for k,v in m.items()}
G,P,W = by(g),by(p),by(w)
keys = sorted(set(G)|set(P)|set(W))
cats = collections.Counter()
for k in keys:
    gv,pv,wv = G.get(k),P.get(k),W.get(k)
    if pv is None and wv is None: cats['ONLY-GOLDEN']+=1; continue
    if gv is None: cats['ONLY-OURS']+=1; print('  ONLY-OURS  %s pris=%s law=%s'%(k,pv,wv)); continue
    if pv==wv:
        if gv==pv: cats['SAME-OK']+=1
        else: cats['STILL-WRONG']+=1; print('  STILL-WRONG %s gold=%s ours=%s'%(k,gv,pv))
    else:
        if gv==wv and gv!=pv: cats['TO-GOLDEN']+=1; print('  TO-GOLDEN  %s gold=%s pris=%s law=%s'%(k,gv,pv,wv))
        elif gv==pv and gv!=wv: cats['AWAY-GOLDEN']+=1; print('  *** AWAY   %s gold=%s pris=%s law=%s'%(k,gv,pv,wv))
        else: cats['MOVED-WRONG']+=1; print('  *** MOVED-WRONG %s gold=%s pris=%s law=%s'%(k,gv,pv,wv))
print('%s  '%a + ' '.join('%s=%d'%(k,v) for k,v in sorted(cats.items())))
PY
done
