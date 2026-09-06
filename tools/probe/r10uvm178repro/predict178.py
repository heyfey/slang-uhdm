#!/usr/bin/env python3
"""r10uvm178repro/predict178.py — THE MOVER PREDICTION, from PRISTINE databases
only.  MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.

Run BEFORE the patched sweep.  Reads the pristine PREF census (golden `g.*` and
ours `o.*`, one pair per row-mode) and names, BY ROW-MODE, every database that
holds at least one cell of § pkgCloneParamRefStaysBare178's face:

    golden BARE  and  ours BOUND  in a package listing that is NOT the
    parameter's own home — i.e. a WILDCARD-IMPORT CLONE copy.

Those row-modes, and only those, may move a byte.  Anything else that moves is
unpredicted and convicts the pass.

usage: predict178.py <censusdir>
"""
import collections
import os
import sys


def load(path, fam='PREF'):
    rows = collections.defaultdict(collections.Counter)
    with open(path) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line.startswith(fam + '|'):
                continue
            key, _, val = line.rpartition('|')
            parts = key.split('|')
            rows['|'.join([parts[0]] + parts[2:])][val] += 1
    return rows


def main():
    if len(sys.argv) < 2:
        sys.stderr.write(__doc__)
        return 2
    d = sys.argv[1]
    tags = sorted({fn[2:-4] for fn in os.listdir(d)
                   if fn.startswith('g.') and fn.endswith('.txt')})
    hits = []
    for tag in tags:
        gp = os.path.join(d, 'g.%s.txt' % tag)
        op = os.path.join(d, 'o.%s.txt' % tag)
        if not (os.path.isfile(gp) and os.path.isfile(op)):
            continue
        G, O = load(gp), load(op)
        cells = []
        for k in sorted(set(G) & set(O)):
            gb = G[k].get('BARE', 0)
            ob = sum(v for kk, v in O[k].items() if kk.startswith('BOUND'))
            if gb and ob:
                cells.append(k)
        if cells:
            hits.append((tag, cells))
    print('PREDICTED MOVERS — row-modes holding at least one face cell')
    for tag, cells in hits:
        print('  %-34s %d cell(s)' % (tag, len(cells)))
        for c in cells:
            print('      %s' % c)
    print('PREDICTED %d row-mode(s) of %d censused' % (len(hits), len(tags)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
