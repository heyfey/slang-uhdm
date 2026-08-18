#!/usr/bin/env python3
import os,re,subprocess,sys
sys.path.insert(0,'/tmp')
exec(open('/tmp/vrgg10_pa.py').read().split('grid = sys.argv[1]')[0])
grid='/tmp/vrgg10_grid8'
def short(a):
    if a is None: return 'NONE'
    a=a.replace('\\_','')
    return a.strip()
for name in sys.argv[1:]:
    d=os.path.join(grid,name)
    g=os.path.join(d,'sl/slpp_all/surelog.uhdm'); b=os.path.join(d,'base.uhdm'); p=os.path.join(d,'pat.uhdm')
    if not all(os.path.exists(x) for x in (g,b,p)): print('%-20s SKIP'%name); continue
    rows={}
    for tag,f in (('gold',g),('base',b),('pat',p)):
        for r in census(f,grid):
            if '.IV' in r.split(' | ')[0]:
                rows.setdefault(tag,[]).append(short(r.split('actual=')[1] if 'actual=' in r else r))
    print('%-20s gold=%-46s base=%-40s pat=%s'%(name,rows.get('gold'),rows.get('base'),rows.get('pat')))
