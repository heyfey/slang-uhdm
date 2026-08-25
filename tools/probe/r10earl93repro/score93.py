#!/usr/bin/env python3
"""r10earl93 -- MEASUREMENT ONLY.  Join one database's golden and ours rows as
a MULTISET (keys collide; a last-writer dict drops rows -- RESUME section 9)
and bucket every cell.

  BOTH-SAME    the key's payload multiset is identical on both sides
  MOVED-WRONG  both sides hold the key, the payload multisets differ
  GOLDEN-ONLY  only golden holds the key
  OURS-ONLY    only we hold the key

DIAG fields (after a literal DIAG) are STRIPPED and never scored.
usage: score93.py <golden.rows> <ours.rows> <tag> [--cells <file>]
"""
import sys, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    try:
        f = open(p)
    except OSError:
        return d
    with f:
        for l in f:
            l = l.rstrip('\n')
            if '\t||\t' not in l:
                continue
            if '\tDIAG\t' in l:
                l = l.split('\tDIAG\t')[0]
            key, pay = l.split('\t||\t', 1)
            d[key][pay] += 1
    return d

g = load(sys.argv[1]); o = load(sys.argv[2]); tag = sys.argv[3]
cells = None
if len(sys.argv) > 5 and sys.argv[4] == '--cells':
    cells = open(sys.argv[5], 'a')
fam = collections.Counter()
for k in set(g) | set(o):
    f = k.split('\t', 1)[0]
    if k not in o:
        fam[(f, 'GOLDEN-ONLY')] += 1
    elif k not in g:
        fam[(f, 'OURS-ONLY')] += 1
    elif g[k] == o[k]:
        fam[(f, 'BOTH-SAME')] += 1
    else:
        fam[(f, 'MOVED-WRONG')] += 1
        if cells:
            cells.write("CELL\t%s\t%s\n" % (tag, k))
            for p, n in sorted(g[k].items()):
                cells.write("  G x%d\t%s\n" % (n, p))
            for p, n in sorted(o[k].items()):
                cells.write("  O x%d\t%s\n" % (n, p))
for (f, b), n in sorted(fam.items()):
    print("%s\t%s\t%s\t%d" % (tag, f, b, n))
if cells:
    cells.close()
