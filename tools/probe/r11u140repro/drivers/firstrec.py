#!/usr/bin/env python3
"""firstrec.py <pairsP.tsv> <pairsL.tsv> : for every row whose strict cell differs between the two sweeps,
the first differing record index and field under each binary (walk position) and a verdict:
LATER (law's first divergence is later in the walk), SAME-FEWER (same record, fewer objects), EQUAL (converted),
else WORSE. Measurement only (r11u140)."""
import sys, subprocess, re
def load(p):
    d = {}
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        d[f[0]] = f
    return d
P = load(sys.argv[1]); L = load(sys.argv[2])
def first(g, o):
    out = subprocess.run(['/tmp/r11u140_bin/uhdm-strictcmp', '--max', '1', g, o], capture_output=True, text=True).stdout
    m = re.search(r'^#(\d+) (\S+)', out, re.M)
    n = re.search(r'objects_differing=(\d+)', out)
    return (int(m.group(1)), m.group(2), int(n.group(1)) if n else 0) if m else None
for k in sorted(P):
    if k not in L: print('MISSING', k); continue
    if P[k][4] == L[k][4] and P[k][3] == L[k][3]: continue
    a = first(P[k][1], P[k][2]); b = first(L[k][1], L[k][2])
    if b is None: v = 'EQUAL'
    elif a is None: v = 'WORSE-FROM-EQUAL'
    elif b[0] > a[0]: v = 'LATER'
    elif b[0] == a[0] and b[2] < a[2]: v = 'SAME-FEWER'
    else: v = 'WORSE?'
    print(k, P[k][4], '->', L[k][4], a, b, v)
