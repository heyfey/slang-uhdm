#!/usr/bin/env python3
"""r10earl57 ladidx56.py — CLEARED-BY-RUNG-INDEX, the guard `ladcmp56.py` lacks.

`ladcmp56.py` calls a pristine rung CLEARED when its golden SITE is absent from
the patched ladder.  Under a WALL-CLOCK budget that conflates two very different
things:

  * a rung the law actually FIXED, and
  * a rung the patched walk simply NEVER REACHED because it spent its budget on
    fewer, deeper rungs.

The second is a BUDGET ARTEFACT and reporting it as a fix is exactly the kind of
claim this campaign has had to retract before.  The discriminator is the PRISTINE
RUNG INDEX: the patched ladder is a prefix-like walk, so the honest comparison
only covers indices up to the LAST pristine rung that is still present in the
patched run.  Anything beyond that is unmeasured, not cleared.

  usage: ladidx56.py <lad_pris.txt> <lad_pat.txt>
"""
import sys, collections

def rungs(p):
    out, cur = [], None
    for line in open(p, errors='replace'):
        line = line.rstrip('\n')
        if line.startswith('RUNG'):
            f = dict(t.split('=', 1) for t in line.split('\t') if '=' in t)
            cur = {'rung': int(line.split('\t')[1]), 'fam': f.get('FAM', '?'),
                   'L': ''}
            out.append(cur)
        elif cur is not None and line.startswith('   L  '):
            cur['L'] = line[6:]
    return out

a = rungs(sys.argv[1])
b = rungs(sys.argv[2])
bs = set(r['L'] for r in b)
cl = [r for r in a if r['L'] not in bs]
present = [r['rung'] for r in a if r['L'] in bs]
horizon = max(present) if present else 0
print('pristine rungs=%d patched rungs=%d site-absent=%d' % (len(a), len(b), len(cl)))
print('COMPARISON HORIZON = pristine rung %d '
      '(the last pristine site still present in the patched ladder);\n'
      'a pristine rung beyond it is UNREACHED, not cleared.' % horizon)
real = [r for r in cl if r['rung'] <= horizon]
unre = [r for r in cl if r['rung'] > horizon]
print('\nCLEARED (index <= horizon)  = %d' % len(real))
for fam, n in collections.Counter(r['fam'] for r in real).most_common():
    idx = [r['rung'] for r in real if r['fam'] == fam]
    print('   %-52s %4d   idx %d..%d' % (fam, n, min(idx), max(idx)))
print('UNREACHED (index > horizon) = %d  -- NOT a fix' % len(unre))
for fam, n in collections.Counter(r['fam'] for r in unre).most_common():
    idx = [r['rung'] for r in unre if r['fam'] == fam]
    print('   %-52s %4d   idx %d..%d' % (fam, n, min(idx), max(idx)))
