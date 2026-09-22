#!/usr/bin/env python3
"""v11u90 VERIFIER's per-cell transition scorer.

For every arm with all three dumps present, score golden-vs-pris and
golden-vs-law PER CELL (the holder's vpiNet and vpiContAssign listings, keyed
by kind|fullname|span, counted as a MULTISET so colliding keys are never
dropped by a last-writer dict), then classify each cell's TRANSITION.

  MOVED-WRONG  a cell that MATCHED golden under pristine and does not under
               the law  -- the only class that can convict the patch.
  TO-GOLDEN    a cell that did not match and now does, or an OURS-ONLY cell
               that is gone.
  AWAY         set-wise: a GOLD-ONLY key that was not GOLD-ONLY before, or an
               OURS-ONLY key that is new.
  UNSCORED     a dump row the lister could not resolve -- printed, never
               dropped.

Arms whose golden or whose binary compile failed are UNSCORED and named.
"""
import os, sys, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
spec = importlib.util.spec_from_file_location('L', os.path.join(os.path.dirname(os.path.abspath(__file__)),'lister90v.py'))
L = importlib.util.module_from_spec(spec)
spec.loader.exec_module(L)

GRID = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('GRID', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid.verifier'))
FIELDS = ('vpiNet', 'vpiContAssign')


def cells(path):
    """(holder, field, key) -> count"""
    out = collections.Counter()
    for h, d in L.listing(path).items():
        for f in FIELDS:
            for e in d.get(f, []):
                out[(h, f, e)] += 1
    return out


def classify(g, o):
    """per-key verdicts, multiset aware"""
    v = {}
    for k in set(g) | set(o):
        a, b = g[k], o[k]
        if a == b:
            v[k] = 'MATCH'
        elif a and not b:
            v[k] = 'GOLD-ONLY'
        elif b and not a:
            v[k] = 'OURS-ONLY'
        else:
            v[k] = 'COUNT'
    return v


tot = collections.Counter()
movedwrong, away, unscored_arms = [], [], []
arms = sorted(d for d in os.listdir(GRID) if os.path.isdir(os.path.join(GRID, d)))
scored = 0
for a in arms:
    d = os.path.join(GRID, a)
    g, p, l = (os.path.join(d, x) for x in ('gold.dump', 'pris.dump', 'lawx.dump'))
    if not all(os.path.exists(x) for x in (g, p, l)):
        unscored_arms.append(a)
        continue
    scored += 1
    G, P, Lw = cells(g), cells(p), cells(l)
    vp, vl = classify(G, P), classify(G, Lw)
    for k in set(vp) | set(vl):
        a0, b0 = vp.get(k, 'ABSENT'), vl.get(k, 'ABSENT')
        tot[(a0, b0)] += 1
        if a0 == 'MATCH' and b0 not in ('MATCH',):
            movedwrong.append((a, k, a0, b0))
        # set-wise AWAY: a gold-only that is NEW, or an ours-only that is NEW
        if b0 == 'GOLD-ONLY' and a0 not in ('GOLD-ONLY', 'COUNT'):
            away.append((a, k, a0, b0))
        if b0 == 'OURS-ONLY' and a0 not in ('OURS-ONLY', 'COUNT'):
            away.append((a, k, a0, b0))
    for k in list(vp) + list(vl):
        if 'UNSCORED' in k[2]:
            tot[('UNSCORED', 'UNSCORED')] += 0

print('arms scored=%d  unscored(no dump trio)=%d' % (scored, len(unscored_arms)))
print('unscored arms:', unscored_arms)
print()
print('PER-CELL TRANSITION MATRIX  (pristine -> law)')
for (a0, b0), n in sorted(tot.items(), key=lambda kv: -kv[1]):
    print('  %-12s -> %-12s %5d' % (a0, b0, n))
print()
pm = sum(n for (a0, b0), n in tot.items() if a0 == 'MATCH')
lm = sum(n for (a0, b0), n in tot.items() if b0 == 'MATCH')
print('MATCH cells: pristine=%d  law=%d' % (pm, lm))
print('MOVED-WRONG (MATCH -> non-MATCH) = %d' % len(movedwrong))
for x in movedwrong[:40]:
    print('   MW', x)
print('AWAY (new GOLD-ONLY or new OURS-ONLY) = %d' % len(away))
for x in away[:40]:
    print('   AWAY', x)
