#!/usr/bin/env python3
"""r10vearl74 — 3-way scorer restricted to the JUDGE fields of the bound
constants, with SELECTABLE field sets so a pre-existing typespec residue cannot
mask (or manufacture) a tag regression.
usage: vscore74.py <golden.rg> <pris.rg> <patched.rg> [--fields ct|all|ts]"""
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
        if mode=='ct':
            out.append('%s{ct=%s val=%s}'%(path,d.get('ct'),d.get('val')))
        elif mode=='ts':
            out.append('%s{ts=%s}'%(path,d.get('ts')))
        elif mode=='sz':
            out.append('%s{sz=%s}'%(path,d.get('sz')))
    return ' '.join(out)
def load(p):
    d=collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('RG '): continue
        f=ln.rstrip('\n').split(' ',2); d[f[1]].append(proj(f[2]))
    for k in d: d[k].sort()
    return d
G,P,Q=(load(a) for a in args[:3])
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
print('fields=%s'%mode, dict(c))
for tag,d in (('AWAY-GOLDEN',away),('MOVED-WRONG',moved)):
    if d:
        print('--- '+tag)
        for (k,gp,pp,qq),n in d.most_common(40):
            print(' x%d %s\n   G %s\n   P %s\n   Q %s'%(n,k,gp,pp,qq))
if still:
    print('--- STILL-WRONG %d cells, %d keys'%(sum(still.values()),len(still)))
