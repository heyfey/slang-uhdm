import re,sys
def load(p):
    d={}
    for ln in open(p):
        m=re.match(r'\s+(\S+)\s+(work@\S+)\s+(\S+)\s+(.*)',ln.rstrip())
        if not m: continue
        sect,name,loc,desc=m.groups()
        mm=re.search(r'ops=\[(.*)\]',desc)
        d[(sect,name)]=mm.group(1).split(' ') if mm else ['NOOP']
    return d
g=load(sys.argv[1]); p=load(sys.argv[2]); l=load(sys.argv[3])
names=sorted(set(g)|set(p)|set(l))
mw=max(len(n[1]) for n in names) if names else 10
nsame=nlawto=nlawaway=0
for n in names:
    G=g.get(n,[]); P=p.get(n,[]); L=l.get(n,[])
    tag=''
    if len(G)!=len(P) or len(G)!=len(L): tag='SHAPE'
    for i in range(max(len(G),len(P),len(L))):
        gg=G[i] if i<len(G) else '-'; pp=P[i] if i<len(P) else '-'; ll=L[i] if i<len(L) else '-'
        if tag=='SHAPE':
            print('  SHAPE %-*s op%-2d g=%-30s p=%-30s l=%s'%(mw,n[1],i,gg,pp,ll)); continue
        if pp==ll:
            if gg!=pp: print('  STILL %-*s op%-2d g=%-30s ours=%s'%(mw,n[1],i,gg,pp))
            continue
        if ll==gg: print('  TO    %-*s op%-2d g=%-30s p=%-30s l=%s'%(mw,n[1],i,gg,pp,ll)); nlawto+=1
        elif pp==gg: print('  AWAY! %-*s op%-2d g=%-30s p=%-30s l=%s'%(mw,n[1],i,gg,pp,ll)); nlawaway+=1
        else: print('  MOVED-WRONG %-*s op%-2d g=%-30s p=%-30s l=%s'%(mw,n[1],i,gg,pp,ll)); nlawaway+=1
print('SUMMARY rows=%d TO=%d AWAY/MOVED-WRONG=%d'%(len(names),nlawto,nlawaway))
