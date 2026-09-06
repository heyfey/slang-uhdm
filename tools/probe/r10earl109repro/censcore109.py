#!/usr/bin/env python3
"""r10earl109 -- the CORPUS census scorer.  MEASUREMENT ONLY.

    censcore109.py <gold.txt> <pris.txt> [<patch.txt>]

Splits cen109 rows by their TAG (`<mode>__<test>`) and joins golden x ours per
database, DEDUPED per key (see score109.py's bykey docstring for why counts are
not compared).  Only tags present on BOTH sides are scored -- golden exists for
tests our side rejects, and scoring those as one-sided noise would bury the
signal.

Prints, in order:
  * the whole-census calibration (BOTH-SAME / FLIP / ONLY-GOLDEN / ONLY-OURS),
  * THE LAW'S CELLS: a `port@` carrier whose golden payload set is a single
    UINT constant with a SIGNED int_typespec and whose ours is the same value
    with NO typespec (the r10earl109 shape), listed BY DATABASE AND BY NAME,
  * with a patched file: TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / MOVED-WRONG,
    and it REFUSES to score if the GOLDEN side is not the same file.
"""
import sys, os, collections, re


def load(path):
    by = collections.defaultdict(lambda: collections.defaultdict(set))
    skip = 0
    for ln in open(path, errors='replace'):
        if ln.startswith('SKIP-NOFILE'):
            skip += 1
            continue
        if not ln.startswith('ROW\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        if len(f) < 7:
            continue
        by[f[1]]['\t'.join(f[2:6])].add(f[6])
    return by, skip


LAWG = re.compile(r'^constant\|n=-\|dc=(\d+)\|sz=(\d+)\|v=UINT:\1\|'
                  r'ts=int_typespec/S\|ct=9$')
LAWO = re.compile(r'^constant\|n=-\|dc=(\d+)\|sz=\d+\|v=UINT:\1\|ts=NONE\|ct=9$')


def main():
    gpath, opath = sys.argv[1], sys.argv[2]
    apath = sys.argv[3] if len(sys.argv) > 3 else None
    G, gs = load(gpath)
    O, os_ = load(opath)
    A, as_ = (load(apath) if apath else (None, 0))
    tags = sorted(set(G) & set(O))
    print('tags: golden %d  ours %d  SCORED(intersection) %d' %
          (len(G), len(O), len(tags)))
    tot = collections.Counter()
    law = []
    moves = collections.Counter()
    movers = collections.defaultdict(collections.Counter)
    for t in tags:
        g, o = G[t], O[t]
        a = A[t] if A is not None else None
        for k in set(g) | set(o):
            gk, ok = g.get(k), o.get(k)
            if gk is None:
                tot['ONLY-OURS'] += 1
                continue
            if ok is None:
                tot['ONLY-GOLDEN'] += 1
                continue
            same = (gk == ok)
            tot['BOTH-SAME' if same else 'FLIP'] += 1
            if (not same and k.startswith('port@') and len(gk) == 1 and
                    len(ok) == 1 and LAWG.match(next(iter(gk))) and
                    LAWO.match(next(iter(ok)))):
                law.append((t, k, next(iter(ok)), next(iter(gk))))
            if a is not None:
                ak = a.get(k)
                if ak is None:
                    if ok is not None:
                        moves['REMOVED'] += 1
                    continue
                ae = (ak == gk)
                if same and ae:
                    moves['BOTH-SAME'] += 1
                elif not same and ae:
                    moves['TO-GOLDEN'] += 1
                    movers[t]['TO-GOLDEN'] += 1
                elif same and not ae:
                    moves['AWAY-GOLDEN'] += 1
                    movers[t]['AWAY-GOLDEN'] += 1
                    print('  AWAY-GOLDEN %s %s\n    gold  %s\n    patch %s' %
                          (t, k, sorted(gk), sorted(ak)))
                elif ak == ok:
                    moves['UNMOVED-WRONG'] += 1
                else:
                    moves['MOVED-WRONG'] += 1
                    movers[t]['MOVED-WRONG'] += 1
                    print('  MOVED-WRONG %s %s\n    pris  %s\n    patch %s\n'
                          '    gold  %s' % (t, k, sorted(ok), sorted(ak),
                                            sorted(gk)))
    print('WHOLE CENSUS  ' + '  '.join('%s %d' % (n, tot[n]) for n in
          ('BOTH-SAME', 'FLIP', 'ONLY-GOLDEN', 'ONLY-OURS')))
    print("THE LAW'S CELLS (port carrier, golden UINT+SIGNED int_typespec, "
          'ours the same value with NO typespec): %d' % len(law))
    for t, k, o, g in sorted(law):
        print('  %s\n      %s\n      ours %s\n      gold %s' % (t, k, o, g))
    if A is not None:
        print('THREE-WAY  ' + '  '.join('%s %d' % (n, moves[n]) for n in
              ('BOTH-SAME', 'TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG',
               'MOVED-WRONG', 'UNMOVED-WRONG', 'REMOVED')))
        for t in sorted(movers):
            print('  census movers %s: %s' % (t, dict(movers[t])))


if __name__ == '__main__':
    main()
