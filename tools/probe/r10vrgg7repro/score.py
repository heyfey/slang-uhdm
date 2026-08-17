#!/usr/bin/env python3
"""r10vrgg7/score.py -- the ORDER-BLIND three-side verdict over the grid.

  usage: score.py <griddir> <label> [<label> ...]

For every (cell, view, instance path) key it prints golden's shape and each
binary's, and classifies each binary per cell:
    FIXED   base disagreed with golden, this binary agrees
    BROKEN  base AGREED with golden, this binary does not   <-- the one that matters
    STILL   both disagree
    OK      both agree
A key present on one side only is MISSING-<side> and is COUNTED -- never OK.
"""
import os, sys, collections

G = sys.argv[1]
LABELS = sys.argv[2:]


def read(path):
    if not os.path.exists(path):
        return None
    out = {}
    for ln in open(path):
        ln = ln.rstrip('\n')
        if ln.startswith('INSTS=') or not ln:
            continue
        f = ln.split('\t')
        if len(f) < 3:
            continue
        out[(f[0], f[1])] = '\t'.join(f[2:])
    return out


tot = collections.Counter()
per = collections.defaultdict(collections.Counter)
for cell in sorted(os.listdir(G)):
    d = os.path.join(G, cell)
    if not os.path.isdir(d):
        continue
    gold = read(os.path.join(d, 'gold.arms'))
    base = read(os.path.join(d, 'base.arms'))
    if gold is None or base is None:
        print('%-22s NOSIDE gold=%s base=%s' % (cell, gold is not None,
                                                base is not None))
        tot['NOSIDE'] += 1
        continue
    for lbl in LABELS:
        cur = read(os.path.join(d, '%s.arms' % lbl))
        if cur is None:
            print('%-22s %-5s MISSING-SIDE' % (cell, lbl))
            per[lbl]['MISSING-SIDE'] += 1
            continue
        keys = sorted(set(gold) | set(base) | set(cur))
        verd = 'OK'
        for k in keys:
            g, b, c = gold.get(k), base.get(k), cur.get(k)
            if g is None or b is None or c is None:
                verd = 'MISSING-KEY'
                break
            if b == g and c != g:
                verd = 'BROKEN'
                break
            if b != g and c == g:
                if verd == 'OK':
                    verd = 'FIXED'
            elif b != g and c != g:
                verd = 'STILL'
        per[lbl][verd] += 1
        if verd != 'OK':
            print('%-22s %-5s %s' % (cell, lbl, verd))
            for k in keys:
                g, b, c = gold.get(k), base.get(k), cur.get(k)
                if not (g == b == c):
                    print('    %-4s %-52s\n      gold=%s\n      base=%s\n      %-4s=%s'
                          % (k[0], k[1], g, b, lbl, c))
for lbl in LABELS:
    print('== %s: %s' % (lbl, dict(per[lbl])))
if tot:
    print('== driver: %s' % dict(tot))
