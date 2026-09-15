#!/usr/bin/env python3
"""r11u38 — the three-way grid score: gold x pristine x law, one row per cell.

    usage: score38.py {dim|pa} <gold.dump> <pristine.dump> <law.dump> [key-substr]

Buckets, and every one of them is PRINTED, never summarised away:
  TO-GOLDEN    pristine != gold, law == gold          (the law's whole point)
  AWAY-GOLDEN  pristine == gold, law != gold          (must be ZERO)
  MOVED-WRONG  pristine != gold, law != gold, moved   (named, never hidden)
  STILL-WRONG  pristine != gold, law == pristine      (an untouched residue)
  UNMOVED      pristine == gold, law == pristine      (the boundary)
  ONE-SIDED    a cell one listing has and another does not (its own bucket, so
               a census that reaches nothing can never read as perfection)
"""
import sys, os
sys.dont_write_bytecode = True  # never leave a __pycache__ in the patch surface
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
mode = sys.argv[1]
if mode == 'dim':
    from dimcen38 import parse
elif mode == 'pa':
    from pacen38 import parse
else:
    sys.exit('mode must be dim or pa')
g = parse(sys.argv[2]); p = parse(sys.argv[3]); l = parse(sys.argv[4])
key = sys.argv[5] if len(sys.argv) > 5 else None
buckets = {k: [] for k in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
                           'STILL-WRONG', 'UNMOVED', 'ONE-SIDED')}
for k in sorted(set(g) | set(p) | set(l)):
    if key and key not in k:
        continue
    if k not in g or k not in p or k not in l:
        buckets['ONE-SIDED'].append((k, g.get(k), p.get(k), l.get(k)))
        continue
    gv, pv, lv = sorted(g[k]), sorted(p[k]), sorted(l[k])
    if pv == gv and lv == gv:
        buckets['UNMOVED'].append((k, gv, pv, lv))
    elif pv == gv and lv != gv:
        buckets['AWAY-GOLDEN'].append((k, gv, pv, lv))
    elif pv != gv and lv == gv:
        buckets['TO-GOLDEN'].append((k, gv, pv, lv))
    elif pv != gv and lv == pv:
        buckets['STILL-WRONG'].append((k, gv, pv, lv))
    else:
        buckets['MOVED-WRONG'].append((k, gv, pv, lv))
for b in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG', 'STILL-WRONG',
          'ONE-SIDED', 'UNMOVED'):
    rows = buckets[b]
    print('== %-12s %d' % (b, len(rows)))
    for k, gv, pv, lv in rows:
        if b == 'UNMOVED':
            print('   %-26s %s' % (k, gv))
        else:
            print('   %-26s\n      G %s\n      P %s\n      L %s' % (k, gv, pv, lv))
print('SCORE ' + ' '.join('%s=%d' % (b, len(buckets[b])) for b in
                          ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
                           'STILL-WRONG', 'ONE-SIDED', 'UNMOVED')))
