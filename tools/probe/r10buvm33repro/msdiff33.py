#!/usr/bin/env python3
# r10buvm33repro/msdiff33.py — ORDER-BLIND MULTISET diff of two uhdm-dump texts
# (arena ids and .sv paths normalised away).  Used to prove a patch adds NO new
# residue key against golden: run it golden-vs-pristine and golden-vs-patched
# and compare the two key sets.  MEASUREMENT ONLY.
#   msdiff33.py <dump A> <dump B>
import sys,collections,re
def load(p):
    c=collections.Counter()
    for ln in open(p,errors='replace'):
        s=ln.strip()
        s=re.sub(r'id:\d+','',s)
        s=re.sub(r'/[^ ,]*\.sv','SV',s)
        if s.startswith('\\_') or s.startswith('|'): c[s]+=1
    return c
a,b=load(sys.argv[1]),load(sys.argv[2])
d=0
for k in sorted(set(a)|set(b)):
    if a[k]!=b[k]:
        print(f"{a[k]:4d} {b[k]:4d}  {k}"); d+=1
print("DIFFKEYS",d)
