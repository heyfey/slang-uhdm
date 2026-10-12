#!/usr/bin/env python3
# v11u297 gsum.py <grid.txt>: one line per case-view: MOVE/---- (md5 or exit code differ P vs L), both strict verdicts with
# uhdm-cmp line counts and exit codes, OFF==P check, and the single switches whose bytes equal pristine.
import sys,collections
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f=l.split()
    if len(f)<4: continue
    cfg,cv,tag=f[0],f[1],f[2]
    d=dict(x.split('=',1) for x in f[3:] if '=' in x)
    if 'SURELOG_FAIL' in l or 'SLANG_FAIL' in l: d={'strict':f[3],'rc':f[-1].split('=')[1],'md5':'-','cmplines':'-'}
    rows[cv][cfg]=d
for cv in sorted(rows):
    r=rows[cv]; P=r.get('P',{}); L=r.get('L',{}); O=r.get('OFF',{})
    mv = P.get('md5')!=L.get('md5') or P.get('rc')!=L.get('rc')
    offok = O.get('md5')==P.get('md5') and O.get('rc')==P.get('rc')
    sw=[k for k in r if k.startswith('R11U297') and r[k].get('md5')==P.get('md5')]
    print(f"{cv:55s} {'MOVE' if mv else '----'} P[{P.get('strict')} cl={P.get('cmplines')} rc={P.get('rc')}] L[{L.get('strict')} cl={L.get('cmplines')} rc={L.get('rc')}] off={'ok' if offok else 'BAD'} restore={','.join(s.replace('R11U297_','').replace('_OFF','') for s in sw) if mv else ''}")
