#!/usr/bin/env python3
# v11u315 grid summary (gsum.py: P vs L of grid.sh; gsum2.py <A,B> of gridfix.sh, flags a case-view leaving STRICT_EQUAL or uhdm-cmp equality)
import sys,re,collections
rows=collections.defaultdict(dict)
for f in sys.argv[1:]:
    for l in open(f):
        p=l.split()
        cfg,cv=p[0],p[1]
        d=dict(x.split('=',1) for x in p[3:] if '=' in x)
        if len(p)>3 and p[3] in('SLANG_FAIL','SURELOG_FAIL'): d['strict']=p[3]
        rows[cv][cfg]=d
mv=ent=leave=0;offbad=0;att=collections.Counter()
for cv in sorted(rows):
    r=rows[cv];P=r.get('P',{});L=r.get('L',{})
    if r.get('OFF',{}).get('md5')!=P.get('md5'): offbad+=1
    if P.get('md5')==L.get('md5') and P.get('rc')==L.get('rc'):
        print('SAME',cv,P.get('strict'),'rc=%s'%P.get('rc'));continue
    mv+=1
    rs=[c for c in r if c.startswith('R11U') and r[c].get('md5')==P.get('md5')]
    a=rs[0] if len(rs)==1 else ('none' if not rs else 'multi')
    att[a]+=1
    e=L.get('strict','').startswith('STRICT_EQUAL') and not P.get('strict','').startswith('STRICT_EQUAL')
    lv=P.get('strict','').startswith('STRICT_EQUAL') and not L.get('strict','').startswith('STRICT_EQUAL')
    ent+=e;leave+=lv
    print('MOVE',cv,'P=%s rcP=%s L=%s rcL=%s cmplines %s->%s restore=%s'%(P.get('strict'),P.get('rc'),L.get('strict'),L.get('rc'),P.get('cmplines'),L.get('cmplines'),a), 'LEAVE' if lv else '')
print('# caseviews',len(rows),'moving',mv,'entering',ent,'leaving',leave,'OFF!=P',offbad,dict(att))
