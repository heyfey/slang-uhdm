#!/usr/bin/env python3
"""r10earl93 -- MEASUREMENT ONLY.  Score ONE grid arm three ways: golden vs
pristine and golden vs patched, as MULTISETS, and classify every key.

  WRONG->RIGHT   pristine differed from golden, patched matches
  RIGHT->WRONG   pristine matched golden, patched differs      (must be 0)
  AWAY-GOLDEN    the patched value moved on a key golden and pristine AGREED
                 on (a superset of RIGHT->WRONG; must be 0)
  STILL-WRONG    differed before and after (the payload may have changed)
  BOTH-SAME      agreed before and after
  GOLDEN-ONLY / OURS-ONLY   the key exists on one side only

usage: score93arm.py <dir> [family]
"""
import sys, os, collections

def load(p, fam):
    d = collections.defaultdict(collections.Counter)
    with open(p) as f:
        for l in f:
            l = l.rstrip('\n')
            if '\t||\t' not in l:
                continue
            if fam and not l.startswith(fam + '\t'):
                continue
            if '\tDIAG\t' in l:
                l = l.split('\tDIAG\t')[0]
            k, p2 = l.split('\t||\t', 1)
            d[k][p2] += 1
    return d

d = sys.argv[1]
fam = sys.argv[2] if len(sys.argv) > 2 else None
g = load(os.path.join(d, 'g.rows'), fam)
o = load(os.path.join(d, 'o.rows'), fam)
q = load(os.path.join(d, 'q.rows'), fam)
c = collections.Counter()
det = []
for k in sorted(set(g) | set(o) | set(q)):
    ing, ino, inq = k in g, k in o, k in q
    if ino != inq or (ino and inq and o[k] != q[k]):
        moved = True
    else:
        moved = False
    if not ing and (ino or inq):
        c['OURS-ONLY'] += 1
        if moved: c['OURS-ONLY-MOVED'] += 1; det.append(('OURS-ONLY-MOVED', k))
        continue
    if ing and not ino and not inq:
        c['GOLDEN-ONLY'] += 1
        continue
    okO = ino and g[k] == o[k]
    okQ = inq and g[k] == q[k]
    if not okO and okQ:
        c['WRONG->RIGHT'] += 1; det.append(('WRONG->RIGHT', k))
    elif okO and not okQ:
        c['RIGHT->WRONG'] += 1; det.append(('RIGHT->WRONG', k))
    elif okO and okQ:
        c['BOTH-SAME'] += 1
        if moved: c['AWAY-GOLDEN'] += 1; det.append(('AWAY-GOLDEN', k))
    else:
        c['STILL-WRONG'] += 1
        if moved: c['STILL-WRONG-MOVED'] += 1
print(os.path.basename(d), fam or 'ALL')
for k in ['WRONG->RIGHT','RIGHT->WRONG','AWAY-GOLDEN','STILL-WRONG',
          'STILL-WRONG-MOVED','BOTH-SAME','GOLDEN-ONLY','OURS-ONLY',
          'OURS-ONLY-MOVED']:
    print("  %-18s %d" % (k, c[k]))
for t, k in det:
    print("   %s\t%s" % (t, k))
