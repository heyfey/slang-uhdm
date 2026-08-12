#!/usr/bin/env python3
"""w58check.py — VERIFIER over-fire / under-fire judge for one arm.

usage: w58check.py <g.dump> <o_before.dump> <o_after.dump>

Reuses vcells.parse (OWN CHILD DEPTH, multiplicity-counted).  For EVERY cell
key it prints a verdict, and it prints TWO criteria side by side because the
last verifier under-counted a finding 4-to-15 by judging on one target kind:

  FULL      the whole cell value (var class + vpiSigned + resolved-ts span)
  CLASS     the var-class multiset alone (ts location and vpiSigned stripped)

VERDICTS on cells whose OURS value MOVED:
  FIX        after == golden, before != golden
  OVER-FIRE  before == golden, after != golden      <- the failure mode
  SIDEWAYS   before != golden and after != golden   <- moved, still wrong
On cells that did NOT move:
  UNDER-FIRE reported only when golden's CLASS mentions ref_var and ours does
             not (the law's own direction), so the count is the law's reach.
"""
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
spec = importlib.util.spec_from_file_location(
    'vc', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'vcells.py'))
_src = open(spec.origin).read().replace('\nmain()', '\n')
vc = type(sys)('vc')
vc.__dict__['__name__'] = 'vc'
exec(compile(_src, spec.origin, 'exec'), vc.__dict__)

if len(sys.argv) < 4:
    sys.exit('usage: w58check.py <g.dump> <o_before.dump> <o_after.dump>')
for p in sys.argv[1:4]:
    if not os.path.exists(p) or os.path.getsize(p) == 0:
        sys.exit('NO_OUTPUT: %s missing or empty (exit 6)' % p)


def bag(cells, classonly):
    d = collections.defaultdict(collections.Counter)
    for n, s, f, pk, k, sg, ts in cells:
        v = k if classonly else '%s%s ts=%s' % (k, ',S' if sg else '', ts)
        d[(n, s, f, pk)][v] += 1
    return d


def fmt(c):
    if c is None:
        return 'ABSENT'
    return '+'.join('%s%s' % (v, ('x%d' % n) if n > 1 else '')
                    for v, n in sorted(c.items()))


G = vc.parse(sys.argv[1])
B = vc.parse(sys.argv[2])
A = vc.parse(sys.argv[3])
print('GOLDEN=%s' % sys.argv[1])
print('BEFORE=%s' % sys.argv[2])
print('AFTER =%s' % sys.argv[3])
for label, classonly in (('FULL', False), ('CLASS', True)):
    gm, bm, am = bag(G, classonly), bag(B, classonly), bag(A, classonly)
    allk = sorted(set(gm) | set(bm) | set(am))
    tally = collections.Counter()
    print('==== criterion %s ====' % label)
    for k in allk:
        g, b, a = fmt(gm.get(k)), fmt(bm.get(k)), fmt(am.get(k))
        if b != a:
            if a == g:
                v = 'FIX'
            elif b == g:
                v = 'OVER-FIRE'
            else:
                v = 'SIDEWAYS'
        else:
            if b != g and 'ref_var' in g and 'ref_var' not in b:
                v = 'UNDER-FIRE'
            elif b != g:
                v = 'residue'
            else:
                v = ''
        tally[v or 'equal'] += 1
        if v in ('FIX', 'OVER-FIRE', 'SIDEWAYS', 'UNDER-FIRE'):
            print('  %-9s %-40s %-15s %-12s g=%-30s b=%-24s a=%s'
                  % (v, k[0][-40:], k[1], k[2], g, b, a))
    print('  TALLY %s: %s' % (label, dict(tally)))
