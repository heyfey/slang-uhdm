#!/usr/bin/env python3
# v11u59 per-cell scorer: the THREE judged fields on a constant
# (expr::Compare -> VpiDecompile, VpiSize; constant::Compare -> VpiConstType).
# Joined by member name + ordinal. Prints TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / STILL-RIGHT.
import subprocess, sys, collections
def cells(d):
    out = subprocess.run(['python3','/tmp/v11u59_cells.py',d],capture_output=True,text=True).stdout
    r=[]; seen=collections.Counter()
    for l in out.split('\n'):
        if not l.startswith('CELL'): continue
        f=l.split()
        mem=f[1]
        if mem=='?': continue
        seen[mem]+=1
        d2=dict(x.split('=',1) for x in f[3:] if '=' in x)
        r.append(((mem,seen[mem]), (d2.get('dec'), d2.get('size'), d2.get('ct'))))
    return dict(r)
arm=sys.argv[1]
g=cells(arm+'/gold.pris.dump'); p=cells(arm+'/ours.pris.dump'); q=cells(arm+'/ours.pat.dump')
tg=ag=sw=sr=0; det=[]
for k in sorted(set(p)|set(q)):
    gv=g.get(k); pv=p.get(k); qv=q.get(k)
    if gv is None or pv is None or qv is None: continue
    if pv==qv:
        (sr if pv==gv else sw).__class__  # no-op
        if pv==gv: sr+=1
        else: sw+=1
        continue
    bp = sum(1 for i in range(3) if pv[i]==gv[i])
    bq = sum(1 for i in range(3) if qv[i]==gv[i])
    if qv==gv: tg+=1; det.append(('TO-GOLDEN-EXACT',k,pv,qv,gv))
    elif bq>bp: tg+=1; det.append(('TOWARD-GOLDEN',k,pv,qv,gv))
    elif bq<bp: ag+=1; det.append(('AWAY-GOLDEN',k,pv,qv,gv))
    else: sw+=1; det.append(('CHANGED-STILL-WRONG',k,pv,qv,gv))
print('%-18s TO-GOLDEN=%d AWAY-GOLDEN=%d CHANGED-STILL-WRONG=%d unchanged(right=%d wrong=%d)'
      % (arm.split('/')[-1], tg, ag, sum(1 for d in det if d[0]=='CHANGED-STILL-WRONG'), sr, sw-sum(1 for d in det if d[0]=='CHANGED-STILL-WRONG')))
for d in det:
    print('    %-20s %-12s pris=%s pat=%s gold=%s' % (d[0], d[1], d[2], d[3], d[4]))
