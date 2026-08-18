#!/usr/bin/env python3
"""r10uvm94 — PREDICT the movers BY NAME from PRISTINE bytes alone.

INTRINSIC: `ct94cen` computes decompileHelper over a database's OWN tree, so
this needs neither a golden nor a patched binary.  It applies THE PATCH'S EXACT
GATE to the pristine census rows:
    the LAST (TRAIL) path element is an indexed_part_select
    AND its Base_expr is a hier_path   (decompileHelper has NO row -> "")
    AND its Width_expr is a constant or a ref_obj
    AND the bracket text the NAME carries today differs from that composition.
usage: pred94.py <census dir of .o files (cen94.sh over a PRISTINE workdir)>
"""
import sys, os, re, glob

d = sys.argv[1]
tot = 0
moved = []
for f in sorted(glob.glob(os.path.join(d, '*.o'))):
    n = 0
    for ln in open(f):
        m = re.search(r'\tCELLS=(.*?)(?:\tSITE=|$)', ln)
        if not m:
            continue
        for c in m.group(1).split(';'):
            if not c.startswith('TRAIL:ELEM=indexed_part_select'):
                continue
            if 'BASEK=hier_path' not in c:
                continue
            if not re.search(r'WIDK=(constant|ref_obj)', c):
                continue
            mb = re.search(r':BRK=(.*?):EXP=(.*?):EXPM=', c)
            if not mb:
                continue
            if mb.group(1) != mb.group(2):
                n += 1
    if n:
        moved.append((os.path.basename(f)[:-2], n))
        tot += n
for name, n in moved:
    print(f'PREDICT-MOVE {name}  cells={n}')
print(f'-- predicted movers: {len(moved)} databases, {tot} cells')
