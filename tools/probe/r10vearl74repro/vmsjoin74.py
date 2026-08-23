#!/usr/bin/env python3
"""r10vearl74 — MULTISET 3-way scorer over range-bound censuses.
A sorted-list pairing mis-attributes multi-range keys (a two-dimension
array_var re-pairs when one bound changes), so every key is scored as a
MULTISET: agreement with golden BEFORE and AFTER.
usage: vmsjoin74.py <golden.rg> <pris.rg> <patched.rg> [--fields=ct|sz|ts|all]"""
import sys, collections, re
mode='all'
args=[a for a in sys.argv[1:] if not a.startswith('--')]
for a in sys.argv[1:]:
    if a.startswith('--fields='): mode=a.split('=')[1]
def proj(pay):
    if mode=='all': return pay
    out=[]
    for m in re.finditer(r'(\S+)\{([^}]*)\}', pay):
        path,body=m.group(1),m.group(2)
        d=dict(kv.split('=',1) for kv in body.split(' ') if '=' in kv)
        if mode=='ct':   out.append('%s{ct=%s val=%s}'%(path,d.get('ct'),d.get('val')))
        elif mode=='ts': out.append('%s{ts=%s}'%(path,d.get('ts')))
        elif mode=='sz': out.append('%s{sz=%s}'%(path,d.get('sz')))
        elif mode=='loc':out.append('%s{loc=%s f=%s}'%(path,d.get('loc'),d.get('f')))
    return ' '.join(out)
def load(p):
    d=collections.defaultdict(collections.Counter)
    for ln in open(p):
        if not ln.startswith('RG '): continue
        f=ln.rstrip('\n').split(' ',2); d[f[1]][proj(f[2])]+=1
    return d
G,P,Q=(load(a) for a in args[:3])
def agree(x,g): return sum(min(n,g[e]) for e,n in x.items())
tot=collections.Counter(); to=[]; aw=[]
for k in sorted(set(G)|set(P)|set(Q)):
    g,p,q=G.get(k,collections.Counter()),P.get(k,collections.Counter()),Q.get(k,collections.Counter())
    tot['golden_cells']+=sum(g.values()); tot['ours_cells']+=sum(q.values())
    ap,aq=agree(p,g),agree(q,g)
    tot['agreeP']+=ap; tot['agreeQ']+=aq
    if aq>ap: tot['TO-GOLDEN']+=aq-ap; to.append((k,aq-ap,g,p,q))
    elif ap>aq: tot['AWAY-GOLDEN']+=ap-aq; aw.append((k,ap-aq,g,p,q))
    if p!=q and aq==ap: tot['CHANGED-NEUTRAL']+=1
print('fields=%s'%mode, dict(tot))
def show(t,rows):
    if not rows: return
    print('--- '+t)
    for k,n,g,p,q in rows[:40]:
        print(' x%d %s'%(n,k))
        for tag,c in (('G',g),('P',p),('Q',q)):
            for e,m in sorted(c.items()): print('   %s x%d %s'%(tag,m,e))
show('AWAY-GOLDEN',aw)
if len(sys.argv)>4 and '--list-to' in sys.argv: show('TO-GOLDEN',to)
