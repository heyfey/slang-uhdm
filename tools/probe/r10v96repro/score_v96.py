import sys, collections, os
def load(p):
    d=collections.defaultdict(collections.Counter)
    if not os.path.exists(p): return d
    for l in open(p, errors='replace'):
        c=l.rstrip('\n').split('\t')
        if len(c)<9: continue
        d[c[0]][(c[1],c[4])]+=1        # KEY = operation SPAN ONLY; payload = (kind, refname)
    return d
tot=collections.Counter(); bad=[]
for d in sorted(sys.argv[1:]):
    G,P,Q=load(d+'/g.cen'),load(d+'/pris.cen'),load(d+'/pat.cen')
    for k in sorted(set(G)|set(P)|set(Q)):
        g,p,q=G[k],P[k],Q[k]
        if p==g and q==g: v='ALREADY-OK'
        elif p!=g and q==g: v='TO-GOLDEN'
        elif p==g and q!=g: v='AWAY'
        else:
            # partial: did the patched multiset get CLOSER to golden?
            dp=sum((g-p).values())+sum((p-g).values()); dq=sum((g-q).values())+sum((q-g).values())
            v='STILL-CLOSER' if dq<dp else ('STILL-FARTHER' if dq>dp else 'STILL')
        tot[v]+=1
        if v in ('AWAY','STILL-FARTHER'):
            bad.append('%-14s %-24s %-20s G=%s PRI=%s PAT=%s'%(v,os.path.basename(d),k,dict(g),dict(p),dict(q)))
print('SPAN-KEYED SCORE over %d arm dirs:'%len(sys.argv[1:]), dict(tot))
for b in bad: print('  '+b)
