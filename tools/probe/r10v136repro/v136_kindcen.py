#!/usr/bin/env python3
# Independent wide-census spot check: class-property variable KIND, golden vs ours.
import re, subprocess, sys, collections
DUMP="/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"
PAT=re.compile(r'\\_([a-z_0-9]+_var): \(([^)]*)\)')
def cells(p):
    out=subprocess.run([DUMP,p],capture_output=True,text=True).stdout
    c=collections.Counter()
    for m in PAT.finditer(out):
        c[(m.group(2), m.group(1))]+=1
    return c
G=cells(sys.argv[1]); O=cells(sys.argv[2])
gk=collections.defaultdict(set); ok=collections.defaultdict(set)
for (n,k) in G: gk[n].add(k)
for (n,k) in O: ok[n].add(k)
dis=[(n,sorted(gk[n]),sorted(ok[n])) for n in gk if n in ok and gk[n]!=ok[n]]
print("NAMES_GOLDEN",len(gk),"NAMES_OURS",len(ok),"KIND_DISAGREEING",len(dis))
for d in dis[:20]: print("  ",d)
