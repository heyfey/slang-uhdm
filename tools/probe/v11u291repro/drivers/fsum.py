# v11u291 fsum.py <fgrid output>: per case-view P/L/F strict verdicts, movers, entering/leaving, and the refinement switch
# that restores the law's bytes on each law -> fix mover.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p=l.split()
    if len(p)<4: continue
    kv=dict(x.split('=',1) for x in p[3:] if '=' in x); kv['st']=p[3]
    rows[p[1]][p[0]]=kv
def se(k): return k.get('strict','').startswith('STRICT_EQUAL') and k.get('cmp')=='0'
c=collections.Counter()
for cv in sorted(rows):
    r=rows[cv]; P,L,F=r['P'],r['L'],r['F']
    if 'md5' not in P: print('NOCMP',cv,P['st'],L['st'],F['st']); continue
    lf = L['md5']!=F['md5']; pf=P['md5']!=F['md5']
    c['views']+=1; c['P->F moving']+=pf; c['L->F moving']+=lf
    c['P->F entering']+= se(F) and not se(P); c['P->F leaving']+= se(P) and not se(F)
    c['FVOFF==L']+= r['FVOFF']['md5']==L['md5']; c['FUOFF==P']+= r['FUOFF']['md5']==P['md5']
    sws=[t[3:] for t in r if t.startswith('FV_') and r[t]['md5']==L['md5']] if lf else []
    if lf: c['L->F sw '+','.join(sws)]+=1
    if lf or pf: print('LF' if lf else '  ', cv.replace('/tmp/v11u291_x/',''), 'P=%s L=%s F=%s'%(P['strict'],L['strict'],F['strict']), 'cmplines %s/%s/%s'%(P['cmplines'],L['cmplines'],F['cmplines']), 'rc %s/%s/%s'%(P['rc'],L['rc'],F['rc']), ','.join(sws))
for k,v in c.items(): print('#',k,v)
