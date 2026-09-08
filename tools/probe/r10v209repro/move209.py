import sys, os, glob
def load(p):
    d={}
    for line in open(p):
        parts=line.rstrip('\n').split('\t')
        if len(parts)<3: continue
        if parts[0]=='VAR': continue
        d[parts[0]]=(parts[1],parts[2])
    return d
tot_mw=0; tot_wr=0; tot_fix=0
for d in sorted(glob.glob('/tmp/<gridscratch>/*/')):
    b=os.path.basename(d.rstrip('/'))
    try:
        g=load(d+'g.cells'); p=load(d+'p.cells'); q=load(d+'q.cells')
    except Exception: continue
    mw=[]; still=[]; fixed=0
    for k,(gv,gs) in g.items():
        pv=p.get(k); qv=q.get(k)
        pok = pv is not None and pv[0]==gv
        qok = qv is not None and qv[0]==gv
        if pok and not qok: mw.append((k,gv,qv[0] if qv else None,gs))
        if not qok and qv is not None: still.append((k,gv,qv[0],gs))
        if (not pok) and qok: fixed+=1
    tot_mw+=len(mw); tot_wr+=len(still); tot_fix+=fixed
    print('== %s  MOVED-WRONG=%d  STILL-WRONG=%d  FIXED=%d' % (b,len(mw),len(still),fixed))
    for k,gv,ov,gs in mw: print('   MOVED-WRONG %s\n      G %s\n      O %s\n      scope %s'%(k,gv,ov,gs))
    for k,gv,ov,gs in still: print('   WRONG %s\n      G %s\n      O %s\n      scope %s'%(k,gv,ov,gs))
print('TOTAL MOVED-WRONG=%d STILL-WRONG=%d FIXED=%d'%(tot_mw,tot_wr,tot_fix))
