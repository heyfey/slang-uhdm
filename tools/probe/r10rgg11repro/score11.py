#!/usr/bin/env python3
"""r10rgg11/score11.py — tabulate GOLDEN's (and ours') PORT-ACTUAL constant per
grid cell.  MEASUREMENT ONLY.

usage: score11.py <gridoutdir> [row-filter-substring]
Prints one line per cell: <cell>  GOLD=<shape>  OURS=<shape>  and a verdict.
"""
import os, sys, collections

O = sys.argv[1]
FILT = sys.argv[2] if len(sys.argv) > 2 else 'ELAB|PORT'


def read(p):
    d = {}
    if not os.path.exists(p):
        return None
    for ln in open(p, errors='replace'):
        if '\t' not in ln:
            continue
        k, v = ln.rstrip('\n').split('\t', 1)
        d.setdefault(k, []).append(v)
    return d


cells = sorted(set(f.rsplit('.', 1)[0] for f in os.listdir(O)
                   if f.endswith('.gold')))
same = diff = miss = 0
tab = collections.Counter()
for c in cells:
    g = read(os.path.join(O, c + '.gold'))
    o = read(os.path.join(O, c + '.ours'))
    if g is None or o is None:
        print('%-46s MISSING' % c); miss += 1; continue
    keys = sorted(set(g) | set(o))
    for k in keys:
        if FILT not in k:
            continue
        gv = ';'.join(g.get(k, ['<absent>']))
        ov = ';'.join(o.get(k, ['<absent>']))
        st = 'SAME' if gv == ov else 'DIFF'
        if st == 'SAME':
            same += 1
        else:
            diff += 1
        tab[(c.split('__')[0], c.split('__')[1], c.split('__')[2],
             c.split('__')[3], gv, ov, st)] += 1
        print('%-46s %-26s %-4s GOLD=%-52s OURS=%s' %
              (c, k.split('|')[-1], st, gv, ov))
print('-- cells=%d rows: SAME=%d DIFF=%d MISSING=%d' % (len(cells), same, diff, miss))
