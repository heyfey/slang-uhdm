import sys, collections
def load(p):
    d=collections.defaultdict(set)
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln: continue
        f=ln.split('|')
        d[(f[0],f[1],f[2])].add('|'.join(f[3:]))
    return d
wd,pv,qv=sys.argv[1],sys.argv[2],sys.argv[3]
show=sys.argv[4] if len(sys.argv)>4 else 'TO-GOLDEN,AWAY-GOLDEN,MOVED-WRONG'
g=load(f'{wd}/g.par'); p=load(f'{wd}/{pv}.par'); q=load(f'{wd}/{qv}.par')
cats=collections.Counter(); rows=[]
for k in sorted(set(g)|set(p)|set(q)):
    G,P,Q=g.get(k),p.get(k),q.get(k)
    if G is None: cats['NO-GOLDEN']+=1; rows.append(('NO-GOLDEN',k,P,Q,G)); continue
    if P is None and Q is None: cats['MISSING-OURS']+=1; rows.append(('MISSING-OURS',k,P,Q,G)); continue
    pr,qr = P==G, Q==G
    c = 'RIGHT' if (pr and qr) else 'TO-GOLDEN' if (qr) else 'AWAY-GOLDEN' if pr else ('MOVED-WRONG' if P!=Q else 'STILL-WRONG')
    cats[c]+=1; rows.append((c,k,P,Q,G))
print(wd,pv,'->',qv,dict(cats))
want=set(show.split(','))
for c,k,P,Q,G in rows:
    if c in want:
        print(' ',c,'|'.join(k),'\n     PRIS',sorted(P or []),'\n     PATC',sorted(Q or []),'\n     GOLD',sorted(G or []))
