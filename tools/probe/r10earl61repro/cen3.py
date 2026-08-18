import sys, collections
pfx=sys.argv[4] if len(sys.argv)>4 else None
def load(p):
    d={}
    for l in open(p,errors='replace'):
        l=l.rstrip('\n')
        if pfx and not l.startswith(pfx): continue
        f=l.split(' ')
        if f[0]=='HC': d[(f[0],f[1],f[2])]=' '.join(f[3:])
        elif f[0]=='PC': d[(f[0],f[1],f[2])]=' '.join(f[3:])
    return d
G,P,A=(load(a) for a in sys.argv[1:4])
keys=set(G)|set(P)|set(A)
to=away=still=0; rows=[]
for k in sorted(keys):
    g,p,a=G.get(k),P.get(k),A.get(k)
    if p==a: continue
    if p!=g and a==g: to+=1; t='TO-GOLDEN'
    elif p==g and a!=g: away+=1; t='AWAY-GOLDEN'
    else: still+=1; t='STILL-WRONG'
    rows.append((t,k,g,p,a))
rows.sort(key=lambda r: (r[0]!='AWAY-GOLDEN', r[0]))
for t,k,g,p,a in rows[:80]:
    print('%-12s %s\n   G=%s\n   P=%s\n   A=%s'%(t,' '.join(k),g,p,a))
print('CENSUS(%s) keys=%d TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d'%(pfx or 'ALL',len(keys),to,away,still))
