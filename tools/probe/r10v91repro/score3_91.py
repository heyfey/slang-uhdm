#!/usr/bin/env python3
"""r10earl91 — THE 3-WAY PER-CELL SCORER.  MEASUREMENT ONLY.

Reads three ct91pat (or ct91cen) row files — GOLDEN, PRISTINE, PATCHED — and
joins them as MULTISETS (RESUME §9: a last-writer dict drops rows).  The cell
is KEY = everything left of the `||` marker; the payload is everything right of
it.  For each key it reports how the OURS multiset moved:

  SAME->SAME     pristine == golden and patched == golden
  WRONG->RIGHT   pristine != golden and patched == golden
  RIGHT->WRONG   pristine == golden and patched != golden      <-- must be 0
  STILL-WRONG    pristine != golden, patched != golden, changed
  UNCHANGED-WRONG pristine != golden, patched == pristine

and, per CHANGED cell, the DIRECTION: EXACT (now equals golden), TO-GOLDEN
(moved and the golden payload exists for that key), AWAY (was equal, now not).

  usage: score3_91.py <gold.rows> <pris.rows> <patched.rows> [--only=SUBSTR]
"""
import collections, sys

def load(p, only):
    d = collections.defaultdict(collections.Counter)
    for l in open(p):
        l = l.rstrip('\n')
        if only and only not in l:
            continue
        if '\t||\t' not in l:
            continue
        k, v = l.split('\t||\t', 1)
        d[k][v] += 1
    return d

def main():
    only = None
    args = []
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            only = a.split('=', 1)[1]
        else:
            args.append(a)
    g, o, q = (load(a, only) for a in args[:3])
    keys = sorted(set(g) | set(o) | set(q))
    tally = collections.Counter()
    changed = []
    for k in keys:
        G, O, Q = g.get(k, collections.Counter()), o.get(k, collections.Counter()), q.get(k, collections.Counter())
        pe, qe = (O == G), (Q == G)
        moved = (Q != O)
        if pe and qe:
            tally['SAME->SAME'] += 1
        elif not pe and qe:
            tally['WRONG->RIGHT'] += 1
        elif pe and not qe:
            tally['RIGHT->WRONG'] += 1
        elif moved:
            tally['STILL-WRONG'] += 1
        else:
            tally['UNCHANGED-WRONG'] += 1
        if moved:
            d = 'EXACT' if qe else ('AWAY' if pe else 'TO-GOLDEN?' if G else 'CHANGED-NO-GOLDEN')
            changed.append((d, k, dict(G), dict(O), dict(Q)))
            tally['DIR:' + d] += 1
    for k in sorted(tally):
        print(f"{k:20} {tally[k]}")
    print(f"{'KEYS':20} {len(keys)}")
    if changed:
        print("-- CHANGED CELLS")
        for d, k, G, O, Q in changed:
            print(f"[{d}] {k}\n    gold={G}\n    pris={O}\n    patc={Q}")

main()
