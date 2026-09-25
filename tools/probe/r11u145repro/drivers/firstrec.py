#!/usr/bin/env python3
"""firstrec.py <pairsP.tsv> <pairsL.tsv> : for every pair whose status or strict cell differs between the pristine
and the law sweep, the first differing strict record (index, type, field) under each binary, and the verdict:
EQUAL (law strict-equal), LATER (the law's first record is further along the walk), SAME-FEWER / SAME-MORE."""
import sys, subprocess, re
def load(p):
    d = {}
    for l in open(p):
        lab, g, o, st, sc = l.rstrip('\n').split('\t'); d[lab] = (g, o, st, sc)
    return d
P, L = load(sys.argv[1]), load(sys.argv[2])
def first(g, o):
    r = subprocess.run(['/tmp/r11u145_bin/strictcmp', '--max', '1', g, o], capture_output=True, text=True)
    m = re.search(r'^#(\d+)\s+(.*)$', r.stdout, re.M)
    n = re.search(r'objects_differing=(\d+)', r.stdout)
    return (int(m.group(1)) if m else None, (m.group(2)[:90] if m else r.stdout.strip().splitlines()[-1][:60]), int(n.group(1)) if n else 0)
for lab in sorted(L):
    if lab not in P: continue
    if P[lab][2:] == L[lab][2:]: continue
    fp = first(P[lab][0], P[lab][1]); fl = first(L[lab][0], L[lab][1])
    if L[lab][2] in ('EQUAL', 'CMP_EQUAL'): v = 'EQUAL'
    elif fp[0] is not None and fl[0] is not None and fl[0] > fp[0]: v = 'LATER'
    elif fp[0] == fl[0]: v = 'SAME-FEWER' if fl[2] <= fp[2] else 'SAME-MORE'
    else: v = 'EARLIER'
    print(f'{v}\t{lab}\t{P[lab][3]} -> {L[lab][3]}\tpristine #{fp[0]} {fp[1]}\tlaw #{fl[0]} {fl[1]}')
