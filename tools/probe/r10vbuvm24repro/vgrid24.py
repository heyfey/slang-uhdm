#!/usr/bin/env python3
"""r10vbuvm24repro/vgrid24.py — THE VERIFIER'S VIEW-GENERAL THREE-WAY SCORER.

    vgrid24.py <cen.golden> <cen.pristine> <cen.patched> [--x] [--show] [--narg]

CELL = one object of a MULTISET keyed on (call loc, call kind, call name).
The key carries NO view label (a def/elab tag classifies the same object
differently on the two sides) and NO argument count (this law changes the
count, and a count in the key turns a FIXED cell into GOLDEN-ONLY/OURS-ONLY).
`--narg` puts the count in the PAYLOAD so it is scored rather than ignored.

Reported per side: objects matching golden (multiset intersection) and
SURPLUS.  Also reported: BROKEN-KEYS — keys where the patched intersection is
SMALLER than the pristine one, i.e. pristine-right -> patched-wrong.  That
number is the load-bearing 0.
"""
import sys, collections

def load(p, col, narg):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p, encoding='utf-8', errors='replace'):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 8 or f[1] != 'CALL':
            continue
        pay = f[col]
        if narg:
            pay = 'n=' + f[5] + ' ' + pay
        d[(f[2], f[3], f[4])][pay] += 1
    return d

def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    col = 7 if '--x' in sys.argv else 6
    narg = '--narg' in sys.argv
    show = '--show' in sys.argv
    G, P, Q = (load(x, col, narg) for x in a[:3])
    keys = sorted(set(G) | set(P) | set(Q))
    ng = np_ = nq = mp = mq = 0
    broken = []
    for k in keys:
        cg, cp, cq = G.get(k, collections.Counter()), P.get(k, collections.Counter()), Q.get(k, collections.Counter())
        ng += sum(cg.values()); np_ += sum(cp.values()); nq += sum(cq.values())
        a1 = sum((cg & cp).values()); b1 = sum((cg & cq).values())
        mp += a1; mq += b1
        if b1 < a1:
            broken.append((k, a1, b1, dict(cg), dict(cp), dict(cq)))
        elif show and b1 != a1:
            print('FIXED\t%s\n  G %s\n  P %s\n  Q %s' % ('\t'.join(k), dict(cg), dict(cp), dict(cq)))
    print('OBJECTS golden %d  pristine %d  patched %d' % (ng, np_, nq))
    print('MATCHING GOLDEN  pristine %d  patched %d   (TO-GOLDEN %+d)' % (mp, mq, mq - mp))
    print('SURPLUS  pristine %d  patched %d' % (np_ - mp, nq - mq))
    print('BROKEN-KEYS (pristine-right -> patched-wrong) %d' % len(broken))
    for k, a1, b1, cg, cp, cq in broken[:40]:
        print('BROKEN\t%s  (%d -> %d)\n  G %s\n  P %s\n  Q %s' % ('\t'.join(k), a1, b1, cg, cp, cq))

main()
