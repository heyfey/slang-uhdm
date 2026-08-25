#!/usr/bin/env python3
"""r10earl85 — score two `pacen85` row files against golden, cell by cell.

MEASUREMENT ONLY; the official uhdm-cmp remains the judge.  Rows are joined as
a MULTISET on the KEY (everything left of the `|`), so a key that repeats is
paired by count and not silently dropped by a last-writer dict.  The PAYLOAD is
compared field by field and every cell lands in exactly one bucket:

  BOTH-SAME     golden == pristine == patched
  WRONG->RIGHT  pristine != golden, patched == golden        (the pass's work)
  RIGHT->WRONG  pristine == golden, patched != golden        (MUST be 0)
  WRONG->OTHER  both wrong, and differently                  (MUST be 0 unless named)
  STILL-WRONG   both wrong, identically                      (a residue)
  ONLY-GOLDEN / ONLY-OURS   key present on one side only

usage: score85.py <g.rows> <o.rows> <q.rows>
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        l = l.rstrip('\n')
        if '|' not in l: continue
        k, v = l.split('|', 1)
        d[k.strip()].append(v.strip())
    for k in d: d[k].sort()
    return d

g, o, q = (load(x) for x in sys.argv[1:4])
b = collections.Counter()
det = []
for k in set(g) | set(o) | set(q):
    gl, ol, ql = g.get(k, []), o.get(k, []), q.get(k, [])
    n = max(len(gl), len(ol), len(ql))
    for i in range(n):
        gv = gl[i] if i < len(gl) else None
        ov = ol[i] if i < len(ol) else None
        qv = ql[i] if i < len(ql) else None
        if gv is None: b['ONLY-OURS'] += 1; continue
        if ov is None or qv is None: b['ONLY-GOLDEN'] += 1; continue
        if ov == gv and qv == gv: b['BOTH-SAME'] += 1
        elif ov != gv and qv == gv: b['WRONG->RIGHT'] += 1; det.append(('WRONG->RIGHT', k, 'pris:   ' + ov, 'patch:  ' + qv))
        elif ov == gv and qv != gv: b['RIGHT->WRONG'] += 1; det.append(('RIGHT->WRONG', k, 'pris:   ' + ov, 'patch:  ' + qv))
        elif ov == qv: b['STILL-WRONG'] += 1; det.append(('STILL-WRONG', k, 'golden: ' + gv, 'both:   ' + qv))
        else: b['WRONG->OTHER'] += 1; det.append(('WRONG->OTHER', k, 'pris:   ' + ov, 'patch:  ' + qv))
for name in ('BOTH-SAME','WRONG->RIGHT','RIGHT->WRONG','WRONG->OTHER','STILL-WRONG','ONLY-GOLDEN','ONLY-OURS'):
    print('%-14s %d' % (name, b[name]))
print()
# NOTE: a STILL-WRONG row prints GOLDEN first and the (identical) pristine =
# patched payload second -- that bucket is a PRE-EXISTING residue, never a move.
for t, k, a, c in sorted(det):
    print('%-13s %s\n     %s\n     %s' % (t, k, a, c))
