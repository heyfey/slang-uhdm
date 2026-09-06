#!/usr/bin/env python3
"""r10earl107 THREE-WAY SCORER -- MEASUREMENT ONLY.

Reads two `cen107 --raw --tagblind` outputs, the PRISTINE one and the PATCHED
one (both carry their own G side, which must be IDENTICAL -- the golden does not
move, and the scorer asserts it), and answers, per key:

  TO-GOLDEN    pristine != golden, patched == golden
  AWAY-GOLDEN  pristine == golden, patched != golden      <- must be 0
  MOVED-WRONG  pristine != patched, neither == golden      <- must be 0
  STILL-WRONG  pristine == patched != golden
  UNCHANGED-OK pristine == patched == golden
  ONLY-ONE-SIDE the key exists on only one of golden / ours

usage: score107.py <pris.raw> <patch.raw> [--carrier port] [--list]
"""
import sys

def load(path):
    g, o = {}, {}
    for ln in open(path):
        ln = ln.rstrip('\n')
        if not ln or ' || ' not in ln:
            continue
        side, rest = ln[0], ln[2:]
        k, v = rest.split(' || ', 1)
        (g if side == 'G' else o)[k] = v
    return g, o

def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    carrier = None
    if '--carrier' in sys.argv:
        carrier = sys.argv[sys.argv.index('--carrier') + 1]
        a = [x for x in a if x != carrier]
    listing = '--list' in sys.argv
    pg, po = load(a[0])
    qg, qo = load(a[1])
    if pg != qg:
        print("FATAL: the GOLDEN side differs between the two runs -- the "
              "scorer was handed two different goldens")
        sys.exit(3)
    keys = set(pg) | set(po) | set(qo)
    if carrier:
        keys = {k for k in keys if k.split('|')[1].strip() == carrier}
    c = dict(TO_GOLDEN=0, AWAY_GOLDEN=0, MOVED_WRONG=0, STILL_WRONG=0,
             UNCHANGED_OK=0, ONLY_ONE_SIDE=0)
    rows = []
    for k in sorted(keys):
        G, P, Q = pg.get(k), po.get(k), qo.get(k)
        if G is None or P is None or Q is None:
            c['ONLY_ONE_SIDE'] += 1
            if P != Q:
                rows.append(('ONE-SIDE-MOVED', k, G, P, Q))
            continue
        if P == G and Q == G:
            c['UNCHANGED_OK'] += 1
        elif P != G and Q == G:
            c['TO_GOLDEN'] += 1
            rows.append(('TO-GOLDEN', k, G, P, Q))
        elif P == G and Q != G:
            c['AWAY_GOLDEN'] += 1
            rows.append(('AWAY-GOLDEN', k, G, P, Q))
        elif P != Q:
            c['MOVED_WRONG'] += 1
            rows.append(('MOVED-WRONG', k, G, P, Q))
        else:
            c['STILL_WRONG'] += 1
    print(' '.join(f"{k}={v}" for k, v in c.items()))
    if listing:
        for t, k, G, P, Q in rows:
            print(f"  {t} {k}\n     G {G}\n     pris {P}\n     patch {Q}")

main()
