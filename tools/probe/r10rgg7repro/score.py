#!/usr/bin/env python3
"""r10rgg7/score.py -- join every grid cell's per-instance arm verdicts.

  usage: score.py <griddir> <label> [<label> ...]
Prints one row per (cell, view, instance): golden's arm, each binary's arm, and
a VERDICT.  A side with NO row for a key prints `-` and is COUNTED as MISSING,
never as agreement.
"""
import sys, os, collections


def load(path):
    rows = {}
    if not os.path.exists(path):
        return rows, -1
    n = -1
    for l in open(path):
        l = l.rstrip('\n')
        if l.startswith('INSTS='):
            n = int(l.split('=')[1].split()[0])
            continue
        p = l.split('\t')
        if len(p) < 6:
            continue
        rows[(p[0], p[1])] = dict(x.split('=', 1) for x in p[2:])
    return rows, n


def main():
    gd = sys.argv[1]
    labels = sys.argv[2:]
    cells = sorted(os.listdir(gd))
    agree = collections.Counter()
    miss = 0
    print('%-14s %-5s %-28s %-10s %-6s %s' %
          ('CELL', 'VIEW', 'INST', 'N', 'GOLD', ' '.join('%-6s' % l for l in labels)))
    for c in cells:
        g, gn = load(os.path.join(gd, c, 'gold.arms'))
        os_ = [load(os.path.join(gd, c, '%s.arms' % l)) for l in labels]
        keys = set(g) | set().union(*[set(o[0]) for o in os_]) if os_ else set(g)
        for k in sorted(keys):
            gv = g.get(k)
            row = [(o[0].get(k) or {}).get('ARM', '-') for o in os_]
            garm = (gv or {}).get('ARM', '-')
            nval = (gv or os_[0][0].get(k) or {}).get('N', '?')
            if '-' in [garm] + row:
                miss += 1
            for i, l in enumerate(labels):
                agree[(l, k[0], garm == row[i])] += 1
            print('%-14s %-5s %-28s %-10s %-6s %s' %
                  (c, k[0], k[1], nval[:10], garm,
                   ' '.join('%-6s' % r for r in row)))
    print('-- MISSING-SIDE rows = %d' % miss)
    for (l, view, ok), n in sorted(agree.items()):
        print('   %s %s agree=%s n=%d' % (l, view, ok, n))


main()
