#!/usr/bin/env python3
"""r10earl91 — THE CORPUS CENSUS JOIN + THE SIZE-PRESENCE FAMILY EXTRACTOR.

Reads a cen91.sh output directory (one `<tag>.gold` / `<tag>.ours` pair per
database) and joins the two sides as MULTISETS per KEY (everything left of the
`\\t||\\t` marker).  Buckets:

  BOTH-SAME      the two multisets are identical
  MOVED-WRONG    the key exists on both sides and the multisets differ
  GOLDEN-ONLY    the key exists only on the golden side
  OURS-ONLY      the key exists only on our side

and, inside MOVED-WRONG, the family this pass owns:

  SZ-EXTRA-PAT0  operand 0 of an assignment pattern where BOTH sides hold the
                 SAME object except that OURS carries a non-zero VpiSize and
                 GOLDEN carries none                       (what the law removes)
  SZ-MISSING-PAT0  the mirror — GOLDEN sizes and we do not    (AWAY territory)
  SZ-DIFF-PAT0   both sides size, at different values

  usage: score91.py <censusdir> [--family] [--tagfilter=SUBSTR]
"""
import collections, os, re, sys

def payload_fields(v):
    return dict(x.split('=', 1) for x in v.split('\t') if '=' in x)

def main():
    d = sys.argv[1]
    family = '--family' in sys.argv
    tagf = None
    for a in sys.argv[2:]:
        if a.startswith('--tagfilter='):
            tagf = a.split('=', 1)[1]
    tally = collections.Counter()
    fam = collections.Counter()
    famrows = []
    tags = [l.strip() for l in open(os.path.join(d, 'INDEX.txt'))]
    for tag in tags:
        if tagf and tagf not in tag:
            continue
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
            g, o = G.get(k, collections.Counter()), O.get(k, collections.Counter())
            if k not in O:
                tally['GOLDEN-ONLY'] += 1
                continue
            if k not in G:
                tally['OURS-ONLY'] += 1
                continue
            if g == o:
                tally['BOTH-SAME'] += 1
                continue
            tally['MOVED-WRONG'] += 1
            kf = payload_fields(k)
            if kf.get('IDX') != '0':
                continue
            # strip SZ from the payload and see whether the rest matches
            def strip(c):
                r = collections.Counter()
                for v, n in c.items():
                    f = payload_fields(v)
                    sz = f.pop('SZ', '-')
                    r[(tuple(sorted(f.items())), )] += n
                return r
            def szs(c):
                r = collections.Counter()
                for v, n in c.items():
                    r[payload_fields(v).get('SZ', '-')] += n
                return r
            # The stripped payload SETS must match; the COUNTS may not, because
            # Earlgrey/testflags holds a PRE-EXISTING extra elaborated copy of
            # some cont_assigns (ours 3 objects where golden has 2).  A strict
            # multiset test here silently DROPS the testflags half of this
            # pass's own population — measured, and the reason the set test is
            # used for family membership while the counts are reported.
            if set(strip(g)) != set(strip(o)):
                continue
            gs, os_ = szs(g), szs(o)
            gz = set(x for x in gs if x not in ('0', '-'))
            oz = set(x for x in os_ if x not in ('0', '-'))
            if not gz and oz:
                fam['SZ-EXTRA-PAT0'] += 1
                famrows.append(('SZ-EXTRA-PAT0', tag, k, dict(gs), dict(os_)))
            elif gz and not oz:
                fam['SZ-MISSING-PAT0'] += 1
                famrows.append(('SZ-MISSING-PAT0', tag, k, dict(gs), dict(os_)))
            elif gz and oz and gz != oz:
                fam['SZ-DIFF-PAT0'] += 1
                famrows.append(('SZ-DIFF-PAT0', tag, k, dict(gs), dict(os_)))
    for k in sorted(tally):
        print(f"{k:18} {tally[k]}")
    for k in sorted(fam):
        print(f"{k:18} {fam[k]}")
    print(f"{'DATABASES':18} {len(tags)}")
    if family:
        print('-- FAMILY ROWS')
        for r in famrows:
            print(f"[{r[0]}] {r[1]}\n    {r[2]}\n    goldSZ={r[3]} oursSZ={r[4]}")

main()
