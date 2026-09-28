#!/usr/bin/env python3
"""r11u198: the full names of the ref_typespec records that sit directly under a constant (a stamped fold), golden
(a.rec) and ours (b.rec) side by side in walk order.  usage: foldnames.py <judge outdir>"""
import sys
def folds(p):
    out, prev = [], None
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        if len(f) < 6:
            continue
        if f[1] == 'ref_typespec' and prev and prev[1] == 'constant' and int(f[0]) == int(prev[0]) + 1:
            out.append('%s@%s:%s' % (f[4], prev[6], prev[7]))
        prev = f
    return out
a, b = folds(sys.argv[1] + '/a.rec'), folds(sys.argv[1] + '/b.rec')
print(' G:', ' '.join(a)); print(' O:', ' '.join(b) if b != a else '(same)')
