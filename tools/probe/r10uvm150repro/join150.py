#!/usr/bin/env python3
"""r10uvm150 census join — MULTISET (keys collide; a dict would drop rows).
Per database: for every census row, compare golden's multiset with pristine's
and with patched's, and classify each row-type:
  FIXED   pristine count != golden, patched count == golden   (TO-GOLDEN)
  BROKEN  pristine count == golden, patched count != golden   (AWAY-GOLDEN)
  MOVED   both wrong, counts changed                          (must be judged)
Rows are the FULL census line, so the SHAPE (element sequence / arg count /
binding / prefix) is part of the identity, not just the site."""
import sys, os, collections
d=sys.argv[1]; names=sys.argv[2:]
tot=collections.Counter()
for base in names:
    g=collections.Counter(open(os.path.join(d,base+'.g')).read().split('\n'))
    o=collections.Counter(open(os.path.join(d,base+'.o')).read().split('\n'))
    q=collections.Counter(open(os.path.join(d,base+'.q')).read().split('\n'))
    per=collections.Counter(); det=[]
    for k in set(g)|set(o)|set(q):
        if not k.strip(): continue
        gc,oc,qc=g.get(k,0),o.get(k,0),q.get(k,0)
        if oc==qc: continue
        if oc!=gc and qc==gc: v='FIXED'
        elif oc==gc and qc!=gc: v='BROKEN'
        else: v='MOVED'
        per[v]+=1; det.append((v,gc,oc,qc,k))
    tot.update(per)
    print('%-24s %s' % (base, dict(per) if per else 'no row changed'))
    for r in sorted(det): print('    %-7s g=%d o=%d q=%d  %s'%r)
print('TOTAL', dict(tot))
