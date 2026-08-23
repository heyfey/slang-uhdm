#!/usr/bin/env python3
"""r10v73 — 3-way MULTISET join of two/three censuses (pacen73 or vcen73 lines).
usage: vjoin73.py <golden> <ours> [--base <base>] [--show N] [--only-key SUBSTR]
Scores per shared cell: TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / STILL-RIGHT.
Span presence (the `| SPAN=` column) is scored SEPARATELY from the judge fields.
"""
import sys, collections
def split(ln):
    if '||' not in ln: return None
    k,p = ln.split('||',1)
    k=k.strip(); p=p.strip()
    if '| SPAN=' in p:
        p,sp = p.split('| SPAN=',1); p=p.strip(); sp=sp.strip()
    else: sp='-'
    return k,p,sp
def load(path):
    d=collections.defaultdict(list)
    for ln in open(path):
        ln=ln.rstrip('\n')
        r=split(ln)
        if not r: continue
        d[r[0]].append((r[1],r[2]))
    for k in d: d[k].sort()
    return d
a=sys.argv[:]
base=None; show=40; onlyk=None
if '--base' in a: i=a.index('--base'); base=load(a[i+1]); del a[i:i+2]
if '--show' in a: i=a.index('--show'); show=int(a[i+1]); del a[i:i+2]
if '--only-key' in a: i=a.index('--only-key'); onlyk=a[i+1]; del a[i:i+2]
G,O=load(a[1]),load(a[2])
ks=set(G)|set(O)
shared=diff=gonly=oonly=spandiff=0
cnt=collections.Counter(); shapes=collections.Counter(); spanc=collections.Counter()
examples=collections.defaultdict(list)
for k in sorted(ks):
    if onlyk and onlyk not in k: continue
    g,o=G.get(k,[]),O.get(k,[])
    n=min(len(g),len(o)); gonly+=max(0,len(g)-n); oonly+=max(0,len(o)-n)
    b=base.get(k,[]) if base is not None else None
    for i in range(n):
        shared+=1
        gi,oi=g[i][0],o[i][0]; gs,os_=g[i][1],o[i][1]
        bi=b[i][0] if b is not None and i<len(b) else None
        if gi!=oi:
            diff+=1; shapes[(gi,oi)]+=1
            if len(examples[(gi,oi)])<3: examples[(gi,oi)].append(k)
        if gs!=os_: spandiff+=1; spanc[(gs,os_)]+=1
        if base is not None:
            if bi==gi and oi==gi: cnt['STILL-RIGHT']+=1
            elif bi!=gi and oi==gi: cnt['TO-GOLDEN']+=1
            elif bi==gi and oi!=gi:
                cnt['AWAY-GOLDEN']+=1
                if len(examples[('AWAY',k)])<1: pass
                if cnt['AWAY-GOLDEN']<=25: print("AWAY %s\n   G: %s\n   B: %s\n   O: %s"%(k,gi,bi,oi))
            elif bi is not None and oi==bi: cnt['STILL-WRONG']+=1
            else:
                cnt['MOVED-WRONG']+=1
                if cnt['MOVED-WRONG']<=25: print("MOVEDWRONG %s\n   G: %s\n   B: %s\n   O: %s"%(k,gi,bi,oi))
print(f"keys G={len(G)} O={len(O)} shared_cells={shared} DIFFERING={diff} gold_only={gonly} ours_only={oonly} SPAN_DIFF={spandiff}")
if base is not None:
    for k in ('STILL-RIGHT','TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-WRONG'):
        print(f"  {k}: {cnt[k]}")
for (gs,os_),n in spanc.most_common(10): print(f"  SPAN x{n}: G={gs} O={os_}")
for (gi,oi),n in shapes.most_common(show):
    print(f"--- x{n}  eg {examples[(gi,oi)][:1]}\n  G: {gi}\n  O: {oi}")
