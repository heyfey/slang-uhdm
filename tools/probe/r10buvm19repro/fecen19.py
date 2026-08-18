#!/usr/bin/env python3
"""r10buvm19repro/fecen19.py — the GRID census, read off the uhdm-dump TEXT.

One row per `foreach_stmt` that is printed as a NODE (a `\\_foreach_stmt:` line
immediately under `|vpiParent:` is a BACK-REFERENCE and is skipped, or every
site would be counted four times), carrying

  * the package VIEW, taken from the enclosing `|uhdmallPackages:` /
    `|uhdmtopPackages:` section header — the axis the whole law turns on;
  * the enclosing subroutine's FULL NAME and the foreach's own `line:col`
    as the key (`gp19::free19` and its wildcard-import clone `imp19::free19`
    are DIFFERENT sites and must not collide);
  * the `vpiVariables` array reference's kind and name, whether it carries a
    `|vpiTypespec:` at all, and that typespec's `|vpiActual:` kind and name.

Field lines of a node sit at the node's indent + 2; the first cut read them at
the node's own indent and reported `NOVAR` for 2 882 of 3 136 rows.

usage: fecen19.py <dump.txt> <out.json>
"""
import sys,re,json
from collections import Counter
path=sys.argv[1]
lines=open(path).read().split('\n')
views=[]
for i,l in enumerate(lines):
    m=re.match(r'^\|(uhdm\w+):',l)
    if m: views.append((i,m.group(1)))
def viewof(i):
    v='?'
    for (j,n) in views:
        if j<=i: v=n
        else: break
    return v
def ind(l): return len(l)-len(l.lstrip(' '))
def fields(i):
    """yield (idx, fieldname) for node line i"""
    base=ind(lines[i]); k=i+1
    while k<len(lines):
        lk=lines[k]
        if not lk.strip(): k+=1; continue
        ik=ind(lk)
        if ik<=base: break
        if ik==base+2 and lk.strip().startswith('|'):
            yield k, lk.strip().rstrip(':').lstrip('|')
        k+=1
def childnode(i):
    """the node line right after field line i"""
    return i+1
rows=[]
for i,l in enumerate(lines):
    s=l.strip()
    if not s.startswith('\\_foreach_stmt:'): continue
    if i>0 and lines[i-1].strip()=='|vpiParent:': continue
    v=viewof(i)
    loc=re.search(r'line:(\d+):(\d+)',s)
    loc=loc.group(0) if loc else '?'
    fn=re.search(r'\((.*?)\)',s); fn=fn.group(1) if fn else ''
    var=None
    for k,f in fields(i):
        if f=='vpiVariables': var=k+1; break
    if var is None:
        rows.append([v,fn,loc,'NOVAR','','','']); continue
    vl=lines[var]
    kind=vl.strip().split(':')[0].lstrip('\\_')
    nm=re.search(r'\((.*?)\)',vl); nm=nm.group(1) if nm else ''
    ts='NOTS'; act=''
    for k,f in fields(var):
        if f=='vpiTypespec':
            ts='TS'
            for k2,f2 in fields(k+1):
                if f2=='vpiActual':
                    act=lines[k2+1].strip().split(':')[0].lstrip('\\_')
                    an=re.search(r'\((.*?)\)',lines[k2+1]); act+='('+(an.group(1) if an else '')+')'
                    break
            break
    rows.append([v,fn,loc,kind,nm,ts,act])
c=Counter((r[0],r[3],r[5],r[6].split('(')[0]) for r in rows)
for k,vv in sorted(c.items()): print(vv,k)
print('TOTAL',len(rows))
json.dump(rows,open(sys.argv[2],'w'))
