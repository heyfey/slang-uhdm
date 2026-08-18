import sys, collections
def load(p):
    d=collections.defaultdict(list)
    for l in open(p):
        c=l.rstrip('\n').split('\t')
        if len(c)!=3: continue
        d[(c[0],c[1])].append(c[2])
    return d
d=sys.argv[1]
G,P,Q=load(d+'/g.cen'),load(d+'/pris.cen'),load(d+'/pat.cen')
n_same=0; changed=[]
for k in sorted(set(G)|set(P)|set(Q)):
    g,p,q=sorted(G.get(k,[])),sorted(P.get(k,[])),sorted(Q.get(k,[]))
    if p==g and q==g: continue
    if p!=g and q==g: continue
    if p==g and q!=g:
        changed.append(('BROKE',k,g,p,q)); continue
    # STILL
    if p==q: n_same+=1
    else: changed.append(('STILL-MOVED',k,g,p,q))
print(d.split('/')[-1], 'STILL-unchanged(P==Q)=%d  STILL-MOVED=%d  BROKE=%d'%(n_same,sum(1 for c in changed if c[0]=='STILL-MOVED'),sum(1 for c in changed if c[0]=='BROKE')))
for c in changed:
    print('  %s %s\n    G=%s\n    P=%s\n    Q=%s'%(c[0],c[1],c[2],c[3],c[4]))
