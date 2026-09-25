#!/usr/bin/env python3
"""samepair.py <golden> <off.uhdm> <on.uhdm>: for two aligned strict walks (same object count), pair the
differing records by WALK INDEX (the same object in both walks) and print, per index, the off and the on
record.  An index only on is a NEW object-difference; an index in both with a changed field is the same
object rendered differently; an index only off is fixed."""
import re, subprocess, sys, os
SC = os.environ['STRICT_CMP']
def recs(g, o):
    r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, errors='replace').stdout
    L = r.splitlines(); d = {}
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m: d[int(m.group(1))] = (m.group(2), L[i+1].strip(), L[i+2].strip())
    return d, [l for l in L if l.startswith('objects') or 'walk diverged' in l]
g, a, b = sys.argv[1:4]
ra, sa = recs(g, a); rb, sb = recs(g, b)
print('off:', sa, 'on:', sb)
for k in sorted(set(ra) | set(rb)):
    x, y = ra.get(k), rb.get(k)
    tag = 'FIXED' if not y else 'NEWOBJ' if not x else 'SAME-REC' if x == y else 'RE-RENDERED'
    print(f'#{k} {tag}')
    if x: print(f'   off {x[0]}: G {x[1][:150]}\n       O {x[2][:150]}')
    if y and y != x: print(f'   on  {y[0]}: G {y[1][:150]}\n       O {y[2][:150]}')
