#!/usr/bin/env python3
"""r10uvm217 — THE ONE-SIDED **NAME** GATE.  MEASUREMENT ONLY.

`cen217.py`'s `BAG-ONLY-OURS` counts one-sided FACES, and a face carries the
per-kind scalars as well as the name — so a pre-existing face residue (§ 209's
R1 `vpiAutomatic` bit on a package-scope container, say) reproduced once more in
a transitive copy shows up there even though the NAME is one golden lists.  The
gate the brief names is stricter and narrower: **a name golden does not hoist
must NOT appear.**  This scores exactly that, over a tree of census triples
(`g.cen` / `p.cen` / `q.cen`) written by `grid217.sh` or `armscore217.sh`:
for every listing cell, the NAME-ONLY multiset difference `ours - golden`, on
the PRISTINE and on the PATCHED census, and every cell where the patched one
gained a name the pristine one did not have.

usage: namebag217.py <scratch dir holding <arm>/{g,p,q}.cen>
"""
import glob
import os
import sys
from collections import Counter, defaultdict


def load(path):
    cells = defaultdict(list)
    for line in open(path, 'rt', errors='replace'):
        f = line.rstrip('\n').split('|')
        if f[0] in ('NET', 'VAR') and len(f) >= 6:
            vec = 'nets' if f[0] == 'NET' else 'vars'
            cells[(f[1], f[2], vec)].append((int(f[3]), f[5]))
    return {k: [x[1] for x in sorted(v)] for k, v in cells.items()}


def main():
    if len(sys.argv) < 2:
        print('usage: namebag217.py <scratch dir>')
        return 2
    root = sys.argv[1]
    tot = {'p': 0, 'q': 0}
    gained = []
    n = 0
    for d in sorted(glob.glob(os.path.join(root, '*'))):
        g = os.path.join(d, 'g.cen')
        if not os.path.isfile(g):
            continue
        n += 1
        G = load(g)
        res = {}
        for tag, f in (('p', 'p.cen'), ('q', 'q.cen')):
            fp = os.path.join(d, f)
            if not os.path.isfile(fp):
                res[tag] = Counter()
                continue
            O = load(fp)
            acc = Counter()
            for k in set(G) | set(O):
                acc.update(Counter(O.get(k, [])) - Counter(G.get(k, [])))
            res[tag] = acc
            tot[tag] += sum(acc.values())
        delta = res['q'] - res['p']
        if delta:
            gained.append((os.path.basename(d), dict(delta)))
    print('arm-views with a golden census: %d' % n)
    print('NAME-ONLY one-sided-OURS total:  pristine=%d  patched=%d'
          % (tot['p'], tot['q']))
    for x in gained:
        print('GAINED-A-NAME %s %s' % x)
    print('-- ARM-VIEWS THAT GAINED A NAME: %d' % len(gained))
    return 0


if __name__ == '__main__':
    sys.exit(main())
