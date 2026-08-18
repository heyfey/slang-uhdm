import sys, subprocess, collections, re
FILT=sys.argv[4] if len(sys.argv)>4 else ''
def cen(p,tag):
    out=subprocess.run(['/tmp/r10rgg17_hpcensus',p,tag],capture_output=True,text=True).stdout
    d=collections.defaultdict(list)
    for ln in out.split('\n'):
        if '\t||\t' not in ln: continue
        k,v=ln.split('\t||\t',1); k=k.split('\t',1)[1]
        if FILT and FILT not in k: continue
        d[k].append(v)
    return d
g=cen(sys.argv[1],'G'); b=cen(sys.argv[2],'B'); p=cen(sys.argv[3],'P')
keys=sorted(set(g)|set(b)|set(p))
fixed=broke=stillw=stillr=0
rows=[]
for k in keys:
    G=sorted(g.get(k,[])); B=sorted(b.get(k,[])); P=sorted(p.get(k,[]))
    ok_b = (G==B); ok_p = (G==P)
    at=re.search(r'AT=([^\t]*)',k).group(1)
    if ok_b and ok_p: stillr+=1; st='STILL-RIGHT'
    elif not ok_b and ok_p: fixed+=1; st='FIXED'
    elif ok_b and not ok_p: broke+=1; st='BROKEN'
    else: stillw+=1; st='STILL-WRONG'
    rows.append((at,st,G,B,P))
print("FIXED",fixed,"BROKEN",broke,"STILL-WRONG",stillw,"STILL-RIGHT",stillr,"keys",len(keys))
for at,st,G,B,P in rows:
    if st in ('FIXED','BROKEN','STILL-WRONG'):
        print('-'*80); print(at,st)
        for x in G: print('  G:',re.sub(r'HPDEF=\t|HPDEC=\t|HPSZ=0\t|RV=-\t','',x))
        for x in P: print('  P:',re.sub(r'HPDEF=\t|HPDEC=\t|HPSZ=0\t|RV=-\t','',x))
