#!/usr/bin/env python3
"""r10uvm178repro/score178.py — the census scorer.  MEASUREMENT ONLY; the
official `uhdm-cmp` is the sole judge of equality.

LHS is ALWAYS golden, RHS is ALWAYS ours.

Reads three census sets (golden / pristine / patched), joins them as MULTISETS
(RESUME.md §9: keys collide, and a last-writer dict silently drops rows), and
scores every cell of the named family:

    TOGOLD      pristine disagreed with golden, patched agrees
    AWAY        pristine AGREED with golden, patched does not   <- the killer
    MOVED-WRONG pristine disagreed, patched still disagrees but DIFFERENTLY
    STILL-WRONG pristine disagreed, patched disagrees the same way
    STILL-OK    agreed before and after

The key is everything left of the last `|` MINUS the row's own TAG field, which
the two producers label differently (RESUME.md §9 — the DEF/ELAB view must stay
out of the key); the VALUE is the last field (BARE / BOUND=...).  A key that
exists on one side only is reported as a one-sided set — never silently
dropped.

usage: score178.py <fam> <goldendir> <pristinedir> <patcheddir> [prefix ...]
"""
import collections
import os
import sys


def load(d, fam, side, names):
    """side: 'g' or 'o'.  Returns {tag: Counter(key -> Counter(value))}."""
    out = collections.defaultdict(lambda: collections.defaultdict(
        collections.Counter))
    if not os.path.isdir(d):
        return out
    for fn in sorted(os.listdir(d)):
        if not fn.startswith(side + '.') or not fn.endswith('.txt'):
            continue
        tag = fn[2:-4]
        if names and not any(tag.startswith(p) for p in names):
            continue
        with open(os.path.join(d, fn)) as f:
            for line in f:
                line = line.rstrip('\n')
                if not line.startswith(fam + '|'):
                    continue
                key, _, val = line.rpartition('|')
                # strip the producer's own TAG field (index 1)
                parts = key.split('|')
                key = '|'.join([parts[0]] + parts[2:])
                out[tag][key][val] += 1
    return out


def main():
    if len(sys.argv) < 5:
        sys.stderr.write(__doc__)
        return 2
    fam = sys.argv[1]
    gd, pd, td = sys.argv[2], sys.argv[3], sys.argv[4]
    names = sys.argv[5:]
    G = load(gd, fam, 'g', names)
    P = load(pd, fam, 'o', names)
    T = load(td, fam, 'o', names)

    tags = sorted(set(G) | set(P) | set(T))
    tot = collections.Counter()
    print('%-26s %7s %7s %7s %7s %7s %7s %7s' %
          ('ROW-MODE', 'GOLD', 'PRIS', 'PATCH', 'TOGOLD', 'AWAY', 'MVWRONG',
           'STILLWR'))
    detail = []
    for tag in tags:
        g, p, t = G.get(tag, {}), P.get(tag, {}), T.get(tag, {})
        keys = set(g) | set(p) | set(t)
        n = collections.Counter()
        n['GOLD'] = sum(sum(v.values()) for v in g.values())
        n['PRIS'] = sum(sum(v.values()) for v in p.values())
        n['PATCH'] = sum(sum(v.values()) for v in t.values())
        for k in sorted(keys):
            gv, pv, tv = g.get(k, collections.Counter()), \
                p.get(k, collections.Counter()), t.get(k, collections.Counter())
            if pv == tv:
                if gv != pv:
                    n['STILLWR'] += 1
                    detail.append('STILL-WRONG %s :: gold=%s ours=%s' %
                                  (k, dict(gv), dict(pv)))
                continue
            # the cell MOVED
            if pv == gv and tv != gv:
                n['AWAY'] += 1
                detail.append('AWAY        %s :: gold=%s pris=%s patch=%s' %
                              (k, dict(gv), dict(pv), dict(tv)))
            elif pv != gv and tv == gv:
                n['TOGOLD'] += 1
                detail.append('TOGOLD      %s :: gold=%s pris=%s patch=%s' %
                              (k, dict(gv), dict(pv), dict(tv)))
            else:
                n['MVWRONG'] += 1
                detail.append('MOVED-WRONG %s :: gold=%s pris=%s patch=%s' %
                              (k, dict(gv), dict(pv), dict(tv)))
        print('%-26s %7d %7d %7d %7d %7d %7d %7d' %
              (tag, n['GOLD'], n['PRIS'], n['PATCH'], n['TOGOLD'], n['AWAY'],
               n['MVWRONG'], n['STILLWR']))
        tot += n
    print('%-26s %7d %7d %7d %7d %7d %7d %7d' %
          ('TOTAL', tot['GOLD'], tot['PRIS'], tot['PATCH'], tot['TOGOLD'],
           tot['AWAY'], tot['MVWRONG'], tot['STILLWR']))
    print()
    print('MOVED CELLS (every one, most-severe first):')
    for line in sorted(detail, key=lambda s: (s.startswith('TOGOLD'),
                                              s.startswith('STILL-WRONG'), s)):
        print('  ' + line)
    return 0


if __name__ == '__main__':
    sys.exit(main())
