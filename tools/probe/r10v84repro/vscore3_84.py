#!/usr/bin/env python3
"""r10v84 — FOUR-database per-cell verdict (golden / pristine / as-submitted /
FIXED).  MEASUREMENT ONLY.  Multiset join on the KEY half.
Prints, for the FIXED binary, the same five verdicts vscore84.py prints, plus
the as-submitted verdict beside it so a fix that MOVED a cell is visible.
usage: vscore3_84.py <dir> [--only-diff]
"""
import sys, collections
d = sys.argv[1]; onlydiff = '--only-diff' in sys.argv
def load(p):
    m = collections.defaultdict(list)
    try:
        for ln in open(p):
            ln = ln.rstrip('\n')
            if '\t||\t' not in ln: continue
            k, v = ln.split('\t||\t', 1); m[k].append(v)
    except FileNotFoundError: pass
    for k in m: m[k].sort()
    return m
G,O,Q,F = (load(f'{d}/{t}.rows') for t in 'goqf')
def verdict(gv, ov, nv):
    if gv == '<ABSENT>': return 'ONLY-OURS'
    if ov == '<ABSENT>' or nv == '<ABSENT>': return 'ONLY-GOLDEN'
    if ov == gv and nv == gv: return 'SAME->SAME'
    if ov != gv and nv == gv: return 'WRONG->RIGHT'
    if ov == gv and nv != gv: return 'RIGHT->WRONG'
    if nv == ov: return 'WRONG->WRONG'
    return 'WRONG->OTHER'
tq = collections.Counter(); tf = collections.Counter(); rows=[]
for k in sorted(set(G)|set(O)|set(Q)|set(F)):
    g,o,q,f = G.get(k,[]),O.get(k,[]),Q.get(k,[]),F.get(k,[])
    n = max(len(g),len(o),len(q),len(f))
    for i in range(n):
        gv = g[i] if i<len(g) else '<ABSENT>'; ov = o[i] if i<len(o) else '<ABSENT>'
        qv = q[i] if i<len(q) else '<ABSENT>'; fv = f[i] if i<len(f) else '<ABSENT>'
        vq, vf = verdict(gv,ov,qv), verdict(gv,ov,fv)
        tq[vq]+=1; tf[vf]+=1
        if not onlydiff or vf!='SAME->SAME' or vq!='SAME->SAME':
            rows.append((vq,vf,k,gv,ov,qv,fv))
for vq,vf,k,gv,ov,qv,fv in rows:
    print(f'[submitted={vq}  FIXED={vf}] {k}')
    if vf!='SAME->SAME' or vq!='SAME->SAME':
        print(f'    G: {gv}'); print(f'    O: {ov}'); print(f'    Q: {qv}'); print(f'    F: {fv}')
print('-- as-submitted: ' + '  '.join(f'{k}={v}' for k,v in sorted(tq.items())))
print('-- FIXED       : ' + '  '.join(f'{k}={v}' for k,v in sorted(tf.items())))
