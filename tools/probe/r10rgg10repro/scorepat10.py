#!/usr/bin/env python3
"""r10rgg10/scorepat10.py — FIXED / BROKEN / STILL / OK over a grid, comparing
the GOLDEN census against the BASE and PATCHED censuses of the same cells."""
import os, sys, collections
O = sys.argv[1]
def load(p):
    d = {}
    if os.path.exists(p):
        for l in open(p):
            k, _, v = l.rstrip('\n').partition('\t'); d[k] = v
    return d
tally = collections.Counter(); det = collections.defaultdict(list)
for f in sorted(os.listdir(O)):
    if not f.endswith('.gold'): continue
    n = f[:-5]
    g = load(os.path.join(O, f)); b = load(os.path.join(O, n + '.ours'))
    p = load(os.path.join(O, n + '.pat'))
    if not p:
        tally['NOPAT'] += 1; det['NOPAT'].append(n); continue
    for k, v in g.items():
        if not k.startswith('ELAB'): continue
        bv = b.get(k, '<MISSING>'); pv = p.get(k, '<MISSING>')
        if bv == v and pv == v: tally['OK'] += 1
        elif bv != v and pv == v: tally['FIXED'] += 1; det['FIXED'].append((n, k))
        elif bv == v and pv != v: tally['BROKEN'] += 1; det['BROKEN'].append((n, k, v, pv))
        else: tally['STILL'] += 1; det['STILL'].append((n, k, v, pv))
print(dict(tally))
for w in ('BROKEN', 'FIXED', 'STILL'):
    print('-- %s (%d)' % (w, len(det[w])))
    for x in det[w][:20]: print('   ', x)
