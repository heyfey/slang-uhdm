#!/usr/bin/env python3
"""r10earl116 — the CORPUS census scorer.  MEASUREMENT ONLY.

Same two families and the same SHAPE scoring as `sig116.py`, but joined PER
DATABASE (the census label is the `<mode>/<test>-<hash>` directory name), so a
moved cell can be named with the row it lives in.  LHS is ALWAYS golden.

usage: cen116.py <gold.txt> <pris.ours.txt> <patch.ours.txt> [-v]
"""
import sys
import collections


def load(path, fam):
    d = collections.defaultdict(collections.Counter)
    for line in open(path):
        if not line.startswith('R|'):
            continue
        f = line.rstrip('\n').split('|')
        if len(f) < 13:
            continue
        key = (f[1], f[2], f[3])          # db, span, Lhs name
        if fam == 'FX':
            key = key + (f[4], f[5], f[6], f[7], f[8])
        d[key][f[11] + ':' + f[12]] += 1
    return d


def main():
    verbose = '-v' in sys.argv
    args = [a for a in sys.argv[1:] if a != '-v']
    for fam in ('FX', 'F0'):
        g = load(args[0], fam)
        p = load(args[1], fam)
        q = load(args[2], fam)
        res = collections.Counter()
        movers = collections.Counter()
        rows = []
        for k in sorted(set(g) | set(p) | set(q)):
            G, P, Q = set(g.get(k, {})), set(p.get(k, {})), set(q.get(k, {}))
            if not G:
                res['NOGOLD'] += 1
                if P != Q:
                    res['NOGOLD_MOVED'] += 1
                    movers[k[0]] += 1
                    rows.append(('NOGOLD_MOVED', k, G, P, Q))
                continue
            if not P and not Q:
                res['GOLDENONLY'] += 1
                continue
            if P == Q:
                res['SAME_AGREE' if P == G else 'STILLWRONG'] += 1
                if P != G:
                    rows.append(('STILLWRONG', k, G, P, Q))
                continue
            movers[k[0]] += 1
            if P != G and Q == G:
                res['TOGOLD'] += 1
                rows.append(('TOGOLD', k, G, P, Q))
            elif P == G and Q != G:
                res['AWAY'] += 1
                rows.append(('AWAY', k, G, P, Q))
            else:
                res['MOVEDWRONG'] += 1
                rows.append(('MOVEDWRONG', k, G, P, Q))
        print("-- %s " % fam + "  ".join("%s=%d" % (k, v)
                                         for k, v in sorted(res.items())))
        print("   ROWS WITH MOVED CELLS: %d" % len(movers))
        for db, n in sorted(movers.items()):
            print("     %-46s cells=%d" % (db, n))
        if verbose:
            for t, k, G, P, Q in rows:
                if t in ('TOGOLD', 'AWAY', 'MOVEDWRONG', 'NOGOLD_MOVED'):
                    print("   [%s %s] %s" % (fam, t, ' | '.join(map(str, k))))
                    print("        G:%s P:%s Q:%s" % (G, P, Q))


if __name__ == '__main__':
    main()
