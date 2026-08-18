import sys
sec=sys.argv[4] if len(sys.argv)>4 else 'ELAB'
def load(p):
    out=[]
    for l in open(p,errors='replace'):
        f=l.rstrip('\n').split('\t')
        if f and f[0]==sec: out.append(f)
    return out
def idx(rows):
    d={}
    for f in rows: d.setdefault((f[1],f[2]),[]).append(f[4] if len(f)>4 else '')
    return d
G,P,A=(idx(load(a)) for a in sys.argv[1:4])
keys=sorted(set(G)|set(P)|set(A))
to=away=still=same=0; rows=[]
for k in keys:
    gv,pv,av=G.get(k),P.get(k),A.get(k)
    if pv==av: same+=1; continue
    if pv!=gv and av==gv: to+=1; tag='TO-GOLDEN'
    elif pv==gv and av!=gv: away+=1; tag='AWAY-GOLDEN'
    else: still+=1; tag='STILL-WRONG'
    rows.append((tag,k,gv,pv,av))
rows.sort(key=lambda r: (r[0]!='AWAY-GOLDEN',r[0]))
for tag,k,gv,pv,av in rows:
    print('%-12s %s.%s\n    G=%s\n    P=%s\n    A=%s'%(tag,k[0],k[1],gv,pv,av))
print('SECTION=%s SUMMARY TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d unchanged=%d'%(sec,to,away,still,same))
