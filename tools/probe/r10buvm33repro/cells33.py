#!/usr/bin/env python3
# r10buvm33repro/cells33.py — per-SOURCE-LINE object comparison of two
# uhdm-dump texts.  MEASUREMENT ONLY.  Prints, for each named source line, the
# objects golden has and ours does not and vice versa, so a grid arm can be read
# CELL BY CELL instead of as one whole-file diff.
#   cells33.py <golden dump> <ours dump> [line,line,...]
import re,sys,collections
# extract every top-of-object line "  \_kind: (fullname), line:L:C, endln:L:C" and key by line
def scan(path):
    out=collections.defaultdict(list)
    for ln in open(path,errors='replace'):
        m=re.search(r'\\_(\w+): \(([^)]*)\), (?:file:[^,]*, )?line:(\d+):(\d+), endln:(\d+):(\d+)', ln)
        if not m: continue
        kind,fn,l,c,el,ec=m.group(1),m.group(2),int(m.group(3)),m.group(4),m.group(5),m.group(6)
        indent=len(ln)-len(ln.lstrip())
        out[l].append((indent,kind,fn,f"{l}:{c}-{el}:{ec}"))
    return out
g=scan(sys.argv[1]); o=scan(sys.argv[2])
lines=sorted(set(list(g)+list(o)))
sel=[int(x) for x in sys.argv[3].split(',')] if len(sys.argv)>3 else lines
for L in lines:
    if L not in sel: continue
    gs={(k,f,s) for _,k,f,s in g.get(L,[])}
    os_={(k,f,s) for _,k,f,s in o.get(L,[])}
    print(f"--- line {L}")
    for t in sorted(gs-os_): print("   G-only:",t)
    for t in sorted(os_-gs): print("   O-only:",t)
    same=gs&os_
    if same: print(f"   both: {len(same)}")
