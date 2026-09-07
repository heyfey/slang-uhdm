#!/usr/bin/env python3
"""r10earl112 -- the ARM SCORER.  MEASUREMENT ONLY.

Reads the three cen112 TSVs of one arm/view directory (golden / pristine /
patched) and scores the PATCHED side against GOLDEN with the PRISTINE side as
the "was it already right?" reference, per KEY, as a MULTISET (cen112 emits
key \t payload \t count, and the same key legitimately carries several
payloads -- one per unrolled generate instance).

  TO-GOLDEN    a payload multiset that was WRONG and is now golden's
  AWAY-GOLDEN  a payload multiset that was GOLDEN and is now not
  STILL-WRONG  wrong before, still wrong (and different from before or not)
  MOVED-WRONG  changed and neither equals golden nor equalled golden before
               (reported separately from STILL-WRONG so a change that merely
               swapped one wrong shape for another cannot hide)
  UNCHANGED-OK / UNCHANGED-BAD

A key present on only ONE side is reported as ONE-SIDED and counted; it is
never silently dropped (a missing key is exactly how a regression hides).

usage: score112.py <cen.gold.txt> <cen.pris.txt> <cen.patch.txt> [label]
"""
import sys
from collections import Counter


def load(path):
    rows, rc = {}, None
    with open(path) as f:
        for line in f:
            line = line.rstrip('\n')
            if line.startswith('CENRC '):
                rc = line.split()[1]
                continue
            parts = line.split('\t')
            if len(parts) < 3:
                continue
            key, pay, cnt = parts[0], parts[1], int(parts[2])
            rows.setdefault(key, Counter())[pay] += cnt
    return rows, rc


def main():
    if len(sys.argv) < 4:
        print('usage: score112.py gold pris patch [label]')
        return 2
    g, grc = load(sys.argv[1])
    p, prc = load(sys.argv[2])
    a, arc = load(sys.argv[3])
    label = sys.argv[4] if len(sys.argv) > 4 else ''
    for name, rc in (('gold', grc), ('pris', prc), ('patch', arc)):
        if rc != '0':
            print(f'{label} CENRC-BAD {name} rc={rc}')
            return 3
    keys = set(g) | set(p) | set(a)
    tally = Counter()
    detail = []
    for k in sorted(keys):
        gk, pk, ak = g.get(k), p.get(k), a.get(k)
        if gk is None or pk is None or ak is None:
            tally['ONE-SIDED'] += 1
            detail.append(('ONE-SIDED', k, gk, pk, ak))
            continue
        wasok, isok = (pk == gk), (ak == gk)
        if wasok and isok:
            tally['UNCHANGED-OK'] += 1
        elif not wasok and isok:
            tally['TO-GOLDEN'] += 1
            detail.append(('TO-GOLDEN', k, gk, pk, ak))
        elif wasok and not isok:
            tally['AWAY-GOLDEN'] += 1
            detail.append(('AWAY-GOLDEN', k, gk, pk, ak))
        elif pk != ak:
            tally['MOVED-WRONG'] += 1
            detail.append(('MOVED-WRONG', k, gk, pk, ak))
        else:
            tally['STILL-WRONG'] += 1
            detail.append(('STILL-WRONG', k, gk, pk, ak))
    print(f'{label} KEYS {len(keys)}  ' +
          '  '.join(f'{n}={tally[n]}' for n in
                    ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG', 'STILL-WRONG',
                     'UNCHANGED-OK', 'UNCHANGED-BAD', 'ONE-SIDED')))
    for verdict, k, gk, pk, ak in detail:
        print(f'  {verdict} {k}')
        print(f'     G {dict(gk) if gk else None}')
        print(f'     P {dict(pk) if pk else None}')
        print(f'     A {dict(ak) if ak else None}')
    return 0


sys.exit(main())
