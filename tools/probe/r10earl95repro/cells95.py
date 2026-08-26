#!/usr/bin/env python3
"""r10earl95 -- CELL DIFF for one arm: golden vs ours, keyed by span, payload
the fields the generated Compares read.  MEASUREMENT ONLY.
  usage: cells95.py <golden.ln95> <ours.ln95> <instance-tag>"""
import re,collections,sys
def load(f, insttag):
    rows=collections.defaultdict(collections.Counter)
    for l in open(f):
        m=re.match(r'(\S+)\s+span=(\d+):(\d+)-(\d+):(\d+)\s+par=(\S+)\s+\((\S+)\s*\)\s+(.*?)\s+HOME=(.*)$',l.rstrip())
        if not m: continue
        kind,l1,c1,l2,c2,par,parsp,extra,home=m.groups()
        if kind not in ('ref_obj','constant'): continue
        home=home.strip()
        if insttag not in home: continue
        if kind=='ref_obj':
            n=re.search(r'name=(\S+)',extra).group(1); a=re.search(r'ACT=(\S+)',extra).group(1)
            v=f"ref({n})ACT={a}"
        else:
            v="const("+re.search(r'val=(\S+)',extra).group(1)+")"
        rows[(int(l1),int(c1),int(l2),int(c2))][v]+=1
    return rows
g=load(sys.argv[1],sys.argv[3]); o=load(sys.argv[2],sys.argv[3])
keys=sorted(set(g)|set(o))
same=diff=0
for k in keys:
    if g[k]==o[k]: same+=1; continue
    diff+=1
    print(f"{k[0]:>3}:{k[1]:<3}-{k[2]}:{k[3]:<3} GOLDEN {dict(g[k])}   OURS {dict(o[k])}")
print(f"-- keys={len(keys)} same={same} DIFF={diff}")
