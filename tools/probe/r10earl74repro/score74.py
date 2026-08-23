#!/usr/bin/env python3
"""r10earl74 — 3-way scorer over range-bound census files.
usage: score74.py <golden.rg> <pristine.rg> <patched.rg>
Reports TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG and lists the
STILL-WRONG and AWAY-GOLDEN cells."""
import sys, collections, re
def load(p):
    d=collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('RG '): continue
        f=ln.rstrip('\n').split(' ',2); d[f[1]].append(f[2])
    for k in d: d[k].sort()
    return d
G,P,Q = (load(a) for a in sys.argv[1:4])
c=collections.Counter(); still=collections.Counter(); away=collections.Counter(); moved=collections.Counter()
for k in sorted(set(list(G))):
    g=G[k]; p=P.get(k,[]); q=Q.get(k,[])
    for i in range(min(len(g),len(p),len(q))):
        gp,pp,qq=g[i],p[i],q[i]
        if pp==qq:
            c['UNCHANGED-EQ' if gp==qq else 'UNCHANGED-NE']+=1
            if gp!=qq: still[(k,gp,qq)]+=1
        elif qq==gp: c['TO-GOLDEN']+=1
        elif pp==gp: c['AWAY-GOLDEN']+=1; away[(k,gp,pp,qq)]+=1
        else: c['MOVED-WRONG']+=1; moved[(k,gp,pp,qq)]+=1
print(dict(c))
def brief(k): return '/'.join([x for x in k.split('/') if not x.startswith('design(')][-3:])
if away:
    print('--- AWAY-GOLDEN')
    for (k,gp,pp,qq),n in away.most_common(): print(' x%d %s\n   G %s\n   P %s\n   Q %s'%(n,brief(k),gp,pp,qq))
if moved:
    print('--- MOVED-WRONG')
    for (k,gp,pp,qq),n in moved.most_common(): print(' x%d %s\n   G %s\n   P %s\n   Q %s'%(n,brief(k),gp,pp,qq))
if still:
    print('--- STILL-WRONG (top 25 keys)')
    for (k,gp,qq),n in still.most_common(25): print(' x%d %s\n   G %s\n   Q %s'%(n,brief(k),gp,qq))
