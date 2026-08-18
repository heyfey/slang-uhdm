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
f=br=sw=sr=0; rows=[]
for k in keys:
    G=sorted(g.get(k,[])); B=sorted(b.get(k,[])); P=sorted(p.get(k,[]))
    ob=(G==B); op=(G==P)
    at=re.search(r'AT=([^\t]*)',k).group(1)
    st='STILL-RIGHT' if (ob and op) else 'FIXED' if (not ob and op) else 'BROKEN' if (ob and not op) else 'STILL-WRONG'
    if st=='FIXED': f+=1
    elif st=='BROKEN': br+=1
    elif st=='STILL-WRONG': sw+=1
    else: sr+=1
    rows.append((at,st,G,B,P))
print("FIXED",f,"BROKEN",br,"STILL-WRONG",sw,"STILL-RIGHT",sr,"keys",len(keys))
for at,st,G,B,P in rows:
    if st in ('FIXED','BROKEN','STILL-WRONG'):
        print('-'*70); print(at,st)
        for x in G: print('  G:',x)
        for x in B: print('  B:',x)
        for x in P: print('  P:',x)
