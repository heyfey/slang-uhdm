#!/usr/bin/env python3
# v11u270: summarize r11u270repro/drivers/controls.sh output (pristine vs law per case-view).
import sys, collections
for fn in sys.argv[1:]:
    d=collections.defaultdict(dict)
    for l in open(fn):
        w=l.split()
        if len(w)<3: continue
        kv=dict(x.split('=',1) for x in w[2:] if '=' in x)
        kv['raw']=' '.join(w[2:])
        d[w[0]][w[1]]=kv
    mv=ent=lea=rcch=cmpch=0; movers=[]; nonzero=0
    for cv,t in d.items():
        p,l=t.get('pristine'),t.get('law')
        if not p or not l: print('MISSING',cv); continue
        if p.get('rc')!='0' or l.get('rc')!='0': nonzero+=1
        if p.get('rc')!=l.get('rc'): rcch+=1
        if p.get('cmplines')!=l.get('cmplines'): cmpch+=1
        if p.get('md5')!=l.get('md5'):
            mv+=1; movers.append((cv,p.get('strict'),l.get('strict')))
            if 'STRICT_EQUAL' in l.get('strict','') and 'STRICT_EQUAL' not in p.get('strict',''): ent+=1
            if 'STRICT_EQUAL' in p.get('strict','') and 'STRICT_EQUAL' not in l.get('strict',''): lea+=1
    print(fn, 'case-views',len(d),'moving',mv,'entering',ent,'leaving',lea,'rc_changes',rcch,'cmplines_changes',cmpch,'nonzero_rc_views',nonzero)
    for m in movers: print('  ',*m)
