#!/usr/bin/env python3
"""r10earl91 — THE hier_path VpiSize CENSUS SCORER.  MEASUREMENT ONLY.

Reads a cen91.sh directory built with ct91cen and answers, for EVERY hier_path
in every database of a sweep, the one question this pass is about:

  who carries a VpiSize, keyed by PKIND (parent kind) x POP/OPIDX (the parent
  operation's type and the position in it) x CTX x PORTPAR (the DEF/ELAB view
  split) x ROOT x LHSTS (the cont_assign target's DECLARED typespec kind).

Buckets, per KEY (multiset join, RESUME §9):

  SZ-BOTH-0      neither side sizes any hier_path under this key
  SZ-BOTH-SET    both sides size, and the VALUES agree
  SZ-VALUE-DIFF  both sides size, values differ                 <- printed
  SZ-OURS-ONLY   we size, golden does not                       <- the family
  SZ-GOLD-ONLY   golden sizes, we do not                        <- AWAY territory
  SHAPE-DIFF     the non-SZ payload differs too (a different law's cell)
  GOLDEN-ONLY / OURS-ONLY   the key exists on one side only

  usage: hpsz91.py <censusdir> [--rows] [--tagfilter=SUBSTR]
"""
import collections, os, sys

def fields(v):
    return dict(x.split('=', 1) for x in v.split('\t') if '=' in x)

def main():
    d = sys.argv[1]
    want_rows = '--rows' in sys.argv
    tagf = None
    for a in sys.argv[2:]:
        if a.startswith('--tagfilter='):
            tagf = a.split('=', 1)[1]
    tally = collections.Counter()
    rows = []
    tags = [l.strip() for l in open(os.path.join(d, 'INDEX.txt'))]
    used = 0
    for tag in tags:
        if tagf and tagf not in tag:
            continue
        used += 1
        G = collections.defaultdict(collections.Counter)
        O = collections.defaultdict(collections.Counter)
        for side, store in (('gold', G), ('ours', O)):
            p = os.path.join(d, tag + '.' + side)
            if not os.path.exists(p):
                continue
            for l in open(p):
                l = l.rstrip('\n')
                if '\t||\t' not in l:
                    continue
                k, v = l.split('\t||\t', 1)
                store[k][v] += 1
        for k in set(G) | set(O):
            if k not in O:
                tally['GOLDEN-ONLY'] += 1
                continue
            if k not in G:
                tally['OURS-ONLY'] += 1
                continue
            g, o = G[k], O[k]
            def strip(c):
                r = collections.Counter()
                for v, n in c.items():
                    f = fields(v)
                    f.pop('SZ', None)
                    r[tuple(sorted(f.items()))] += n
                return r
            def szset(c):
                return set(fields(v).get('SZ', '0') for v in c)
            if set(strip(g)) != set(strip(o)):
                tally['SHAPE-DIFF'] += 1
                continue
            gz = set(x for x in szset(g) if x not in ('0', '-'))
            oz = set(x for x in szset(o) if x not in ('0', '-'))
            if not gz and not oz:
                tally['SZ-BOTH-0'] += 1
            elif gz and oz and gz == oz:
                tally['SZ-BOTH-SET'] += 1
            elif gz and oz:
                tally['SZ-VALUE-DIFF'] += 1
                rows.append(('SZ-VALUE-DIFF', tag, k, sorted(gz), sorted(oz)))
            elif oz:
                tally['SZ-OURS-ONLY'] += 1
                rows.append(('SZ-OURS-ONLY', tag, k, sorted(gz), sorted(oz)))
            else:
                tally['SZ-GOLD-ONLY'] += 1
                rows.append(('SZ-GOLD-ONLY', tag, k, sorted(gz), sorted(oz)))
    for k in sorted(tally):
        print(f"{k:16} {tally[k]}")
    print(f"{'DATABASES':16} {used}")
    if want_rows:
        print('-- ROWS')
        for r in rows:
            print(f"[{r[0]}] {r[1]}\n    {r[2]}\n    goldSZ={r[3]} oursSZ={r[4]}")

main()
