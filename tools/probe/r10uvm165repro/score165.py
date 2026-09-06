#!/usr/bin/env python3
# r10uvm165repro/score165.py — the CELL SCORER.  MEASUREMENT ONLY; the official
# `uhdm-cmp` is the judge.  LHS is ALWAYS golden (Surelog), RHS ALWAYS ours.
#
#   score165.py <grid workdir> [REF|CAS]
#
# Reads grid165.sh's three censuses per view (golden / pristine / patched) and
# scores every cell whose value multiset MOVED between the two binaries as
# TOWARD / AWAY / SIDEWAYS / NO-GOLDEN, and prints the arm's golden distance in
# each view before and after.
#
# TWO TRAPS THIS TOOL IS WRITTEN AROUND, both from RESUME.md §9:
#   * MULTISET, never a dict.  An ELAB database of a package holds the class
#     body TWICE (the def listing and the elaborated one) at the SAME span with
#     the SAME parent chain, so a last-writer dict silently drops one of them
#     and reported "0 moved" for a view in which nine cells had moved.  Every
#     count here is a Counter.
#   * A key whose two sides hold DIFFERENT NUMBERS of objects cannot be scored
#     TOWARD or AWAY by value alone, so the PER-KEY DISTANCE to golden is
#     printed for those (`dist pris=<n> pat=<n>`): equal distances mean the
#     pre-existing surplus is untouched, and that is what must be said rather
#     than a label that reads like a regression or like a fix.
import sys, collections

FAMS = {'REF': (2, 6), 'CAS': (2, 8)}      # key slice, value index


def load(p, fam):
    lo, vi = FAMS[fam]
    c = collections.Counter()
    for l in open(p):
        if not l.startswith(fam + '|'):
            continue
        f = l.rstrip('\n').split('|')
        c[(tuple(f[lo:vi]), f[vi])] += 1
    return c


def bykey(c):
    d = collections.defaultdict(collections.Counter)
    for (k, v), n in c.items():
        d[k][v] += n
    return d


def dist(x, y):
    return sum((x - y).values()) + sum((y - x).values())


def main():
    W = sys.argv[1]
    fam = sys.argv[2] if len(sys.argv) > 2 else 'REF'
    T = collections.Counter()
    for view in ('def', 'elab'):
        g = load(f'{W}/cen.g.{view}.txt', fam)
        a = load(f'{W}/cen.a.{view}.txt', fam)
        b = load(f'{W}/cen.b.{view}.txt', fam)
        print(f"-- {view} {fam}: golden-vs-PRISTINE {dist(g, a)}   "
              f"golden-vs-PATCHED {dist(g, b)}")
        ga, aa, ba = bykey(g), bykey(a), bykey(b)
        for k in sorted(set(aa) | set(ba)):
            av, bv = aa.get(k, collections.Counter()), ba.get(k, collections.Counter())
            if av == bv:
                continue
            gv = ga.get(k, collections.Counter())
            n = max(1, sum(abs(bv.get(x, 0) - av.get(x, 0))
                           for x in set(av) | set(bv)) // 2)
            if bv == gv:
                v = 'TOWARD'
            elif av == gv:
                v = 'AWAY'
            elif not gv:
                v = 'NO-GOLDEN'
            else:
                v = 'SIDEWAYS'
            T[v] += n
            T['MOVED'] += n
            extra = ''
            if v == 'SIDEWAYS':
                extra = f"  dist pris={dist(gv, av)} pat={dist(gv, bv)}"
            print(f"   {view} {v:<9} {'|'.join(k)}  G={dict(gv)} "
                  f"pris={dict(av)} pat={dict(bv)}{extra}")
    print('TOTALS', dict(T))


if __name__ == '__main__':
    main()
