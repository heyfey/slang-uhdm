import sys, collections
def load(p):
    d=collections.defaultdict(set)
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln: continue
        f=ln.split('|'); d[(f[0],f[1],f[2])].add('|'.join(f[3:]))
    return d
wd,pv,qv=sys.argv[1:4]
g=load(f'{wd}/g.sig'); p=load(f'{wd}/{pv}.sig'); q=load(f'{wd}/{qv}.sig')
cats=collections.Counter(); away=[]
for k in sorted(set(g)|set(p)|set(q)):
    G,P,Q=g.get(k),p.get(k),q.get(k)
    if G is None: cats['NO-GOLDEN']+=1; continue
    if P is None and Q is None: cats['MISSING-OURS']+=1; continue
    pr,qr=P==G,Q==G
    c='RIGHT' if pr and qr else 'TO-GOLDEN' if qr else 'AWAY-GOLDEN' if pr else ('MOVED-WRONG' if P!=Q else 'STILL-WRONG')
    cats[c]+=1
    if c=='AWAY-GOLDEN': away.append((k,sorted(P),sorted(Q),sorted(G)))
print(wd,pv,'->',qv,dict(cats))
for a in away: print('  AWAY',a)
