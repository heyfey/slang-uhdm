#!/usr/bin/env python3
"""r10rgg11/scorepat11.py — FIXED / BROKEN / OK / STILL of a patched grid run
against the SAME golden census the base run was scored on.

    OK      base agreed with golden and still does
    FIXED   base disagreed, patched agrees          <- the law's reach
    BROKEN  base AGREED, patched disagrees          <- MUST BE ZERO
    STILL   both disagree                           <- named residues

usage: scorepat11.py <base-outdir> <pat-outdir> [row-filter]
"""
import os, sys, collections

BASE, PAT = sys.argv[1], sys.argv[2]
FILT = sys.argv[3] if len(sys.argv) > 3 else 'ELAB|PORT'


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


cells = sorted(set(f.rsplit('.', 1)[0] for f in os.listdir(BASE) if f.endswith('.gold')))
cnt = collections.Counter()
for c in cells:
    g = read(os.path.join(BASE, c + '.gold'))
    b = read(os.path.join(BASE, c + '.ours'))
    p = read(os.path.join(PAT, c + '.ours'))
    if g is None or b is None or p is None:
        cnt['MISSING'] += 1
        print('%-46s MISSING' % c)
        continue
    for k in sorted(set(g) | set(b) | set(p)):
        if FILT not in k:
            continue
        gv = ';'.join(g.get(k, ['<absent>']))
        bv = ';'.join(b.get(k, ['<absent>']))
        pv = ';'.join(p.get(k, ['<absent>']))
        if bv == gv and pv == gv:
            st = 'OK'
        elif bv != gv and pv == gv:
            st = 'FIXED'
        elif bv == gv and pv != gv:
            st = 'BROKEN'
        else:
            st = 'STILL'
        cnt[st] += 1
        if st in ('FIXED', 'BROKEN'):
            print('%-46s %-8s %-22s GOLD=%-52s BASE=%-52s PAT=%s' %
                  (c, st, k.split('|')[-1], gv, bv, pv))
print('-- cells=%d  OK=%d FIXED=%d BROKEN=%d STILL=%d MISSING=%d' %
      (len(cells), cnt['OK'], cnt['FIXED'], cnt['BROKEN'], cnt['STILL'],
       cnt['MISSING']))
