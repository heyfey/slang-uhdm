#!/usr/bin/env python3
# v11u315 grid summary (gsum.py: P vs L of grid.sh; gsum2.py <A,B> of gridfix.sh, flags a case-view leaving STRICT_EQUAL or uhdm-cmp equality)
import sys,collections
rows=collections.defaultdict(dict)
for f in sys.argv[2:]:
    for l in open(f):
        p=l.split(); cfg,cv=p[0],p[1]
        d=dict(x.split('=',1) for x in p[3:] if '=' in x)
        if len(p)>3 and p[3] in('SLANG_FAIL','SURELOG_FAIL'): d['strict']=p[3]; d['cmp']=p[3]
        rows[cv][cfg]=d
A,Bc=sys.argv[1].split(',')
mv=ent=lv=jl=0; att=collections.Counter(); chk=collections.Counter()
se=lambda d:d.get('strict','').startswith('STRICT_EQUAL')
for cv in sorted(rows):
    r=rows[cv]; a=r.get(A,{}); b=r.get(Bc,{})
    chk['OFF==P']+= r.get('OFF',{}).get('md5')==r.get('P',{}).get('md5')
    chk['VOFF==LAW']+= r.get('VOFF',{}).get('md5')==r.get('LAW',{}).get('md5')
    chk['total']+=1
    if a.get('md5')==b.get('md5') and a.get('rc')==b.get('rc'): continue
    mv+=1
    rs=[c for c in r if c.startswith('R11') and r[c].get('md5')==a.get('md5')]
    at=rs[0] if len(rs)==1 else ('none' if not rs else 'multi'); att[at]+=1
    e=se(b) and not se(a); l=se(a) and not se(b); j=a.get('cmp')=='0' and b.get('cmp')!='0'
    ent+=e; lv+=l; jl+=j
    print('MOVE',cv,'%s=%s %s=%s cmplines %s->%s rc %s->%s restore=%s'%(A,a.get('strict'),Bc,b.get('strict'),a.get('cmplines'),b.get('cmplines'),a.get('rc'),b.get('rc'),at),'LEAVE' if l else '','JUDGE_LEAVE' if j else '')
print('#',A,'->',Bc,'caseviews',len(rows),'moving',mv,'entering',ent,'leaving',lv,'judge_leaving',jl,dict(att),dict(chk))
