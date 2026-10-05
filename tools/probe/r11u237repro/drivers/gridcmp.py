#!/usr/bin/env python3
# (r11u237: fence check added: reads $FENCED fail-closed and refuses a fenced case.)
# r11u237: gridcmp.py <grid file> <tag A> <tag B>: per case-view status (EQ / SNE / CMPNE) and bytes, A against B; prints every change and a SUMMARY (with the exit-code pairs).
import sys,collections,re
import os as _os, re as _re
_F = _os.environ.get('FENCED', '').split()
if len(_F) != 4: raise SystemExit('fence: FENCED must hold the four names (source drivers/env.sh)')
_FRE = _re.compile(r'\b(' + '|'.join(map(_re.escape, _F)) + r')\b')
def _fenced(p): return bool(_FRE.search(p))
# gridcmp: lines "rel tag cmp=.. cmplines=.. strict=.. rc=.. md5=.."; compare tag A vs tag B per rel
f,a,b=sys.argv[1:4]
d=collections.defaultdict(dict)
bad=[]
for ln in open(f):
    p=ln.split()
    if len(p)<3 or '=' not in ln: bad.append(ln.strip()); continue
    rel,tag=p[0],p[1]
    if _fenced(rel): raise SystemExit('gridcmp: fenced case in the grid file')
    kv=dict(x.split('=',1) for x in p[2:] if '=' in x)
    if 'cmp' not in kv: kv['status']=p[2]
    d[rel][tag]=kv
def st(kv):
    if 'status' in kv: return kv['status']
    s=kv['strict']
    if kv['cmp']!='0': return 'CMPNE'
    if s.startswith('STRICT_EQUAL'): return 'EQ'
    if s.startswith('STRICT_NOTEQUAL'): return 'SNE'
    return s
cnt=collections.Counter(); rcs=collections.Counter()
for rel in sorted(d):
    if a not in d[rel] or b not in d[rel]: cnt['missing']+=1; print('MISSING',rel); continue
    A,B=d[rel][a],d[rel][b]
    rcs[(A.get('rc'),B.get('rc'))]+=1
    sa,sb=st(A),st(B)
    same=A.get('md5')==B.get('md5')
    if sa!=sb: cnt[f'{sa}->{sb}']+=1; print(f'{rel}: {sa} -> {sb}  ({A.get("strict")} -> {B.get("strict")}) cmplines {A.get("cmplines")}->{B.get("cmplines")}')
    elif not same:
        cnt['bytes-moved-same-status']+=1
        if A.get('strict')!=B.get('strict') or A.get('cmplines')!=B.get('cmplines'):
            print(f'{rel}: {sa} moved ({A.get("strict")} -> {B.get("strict")}) cmplines {A.get("cmplines")}->{B.get("cmplines")}')
    else: cnt['identical']+=1
print('SUMMARY',dict(cnt),'rc pairs',dict(rcs),'unparsed',len(bad))
