#!/usr/bin/env python3
"""r10uvm183 — the grid SCORER.  MEASUREMENT ONLY; LHS is ALWAYS golden.

Two projections per `foreach` site, scored independently:

  KIND — the ARRAY-REFERENCE typespec's kind+name+span, the field the law's
         DEGRADE half owns.
  INST — the same cell's `vpiInstance` package NAME, the field the law's
         INSTANCE half owns.

and a third the law must NOT touch:

  CNT  — how many COPIES of each site the database lists.

For each projection, per arm and per view:

  TOWARD       pristine != golden, patched == golden
  AWAY         pristine == golden, patched != golden        (must be 0)
  MOVED-WRONG  patched != pristine and patched != golden    (must be 0)
  agree/before-after are printed so an arm that never disagreed is visible as
  such — an arm AGREEING is not an arm TESTING (RESUME.md §9).

Usage: score183.py <arm workdir> [--all]
"""
import collections
import os
import re
import sys


def load(path):
    """-> {(line:col, tf, scope-name-without-id): Counter(projection-tuple)}"""
    kind = collections.defaultdict(collections.Counter)
    inst = collections.defaultdict(collections.Counter)
    cnt = collections.Counter()
    if not os.path.exists(path):
        return None, None, None
    with open(path) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 8 or p[0] != 'FE':
                continue
            scope = re.sub(r'#\d+$', '', p[3])
            key = (p[1], p[2], scope)
            kind[key][p[5].split('=', 1)[1]] += 1
            iv = re.sub(r'#\d+', '', p[6].split('=', 1)[1])
            inst[key][iv] += 1
            cnt[key] += 1
    return kind, inst, cnt


def score(g, a, b):
    """g golden, a pristine, b patched -> counters + the moved cells"""
    c = collections.Counter()
    moved = []
    for k in sorted(set(g) | set(a) | set(b)):
        cg, ca, cb = g.get(k), a.get(k), b.get(k)
        cg = cg if cg is not None else collections.Counter()
        ca = ca if ca is not None else collections.Counter()
        cb = cb if cb is not None else collections.Counter()
        if ca == cb:
            c['agree-before-after' if ca == cg else 'still-off'] += 1
            continue
        if cb == cg:
            c['TOWARD'] += 1
            moved.append(('TOWARD', k, ca, cb, cg))
        elif ca == cg:
            c['AWAY'] += 1
            moved.append(('AWAY', k, ca, cb, cg))
        else:
            # Neither side equals golden.  A cell can still have moved
            # STRICTLY TOWARD it: more of its copies now carry golden's value
            # and none that already did was lost.  Scoring that as
            # MOVED-WRONG would call an improvement a regression, and scoring
            # it as TOWARD would hide that the cell has NOT arrived — so it
            # gets its own column, and the residue that keeps it short is
            # printed with it.
            gain_b = sum((cb & cg).values())
            gain_a = sum((ca & cg).values())
            lost = (ca & cg) - cb
            if gain_b > gain_a and not lost:
                c['TOWARD-PARTIAL'] += 1
                moved.append(('TOWARD-PARTIAL', k, ca, cb, cg))
            elif gain_b < gain_a or lost:
                c['MOVED-WRONG'] += 1
                moved.append(('MOVED-WRONG', k, ca, cb, cg))
            else:
                c['MOVED-SIDEWAYS'] += 1
                moved.append(('MOVED-SIDEWAYS', k, ca, cb, cg))
    return c, moved


def main():
    w = sys.argv[1]
    showall = '--all' in sys.argv
    for view in ('def', 'elab'):
        gk, gi, gc = load(os.path.join(w, 'cen.g.%s.txt' % view))
        ak, ai, ac = load(os.path.join(w, 'cen.a.%s.txt' % view))
        bk, bi, bc = load(os.path.join(w, 'cen.b.%s.txt' % view))
        if gk is None or ak is None or bk is None:
            print('%-5s MISSING CENSUS' % view)
            continue
        sites = len(set(gk) | set(ak) | set(bk))
        for name, (g, a, b) in (('KIND', (gk, ak, bk)),
                                ('INST', (gi, ai, bi))):
            c, moved = score(g, a, b)
            print('%-5s %-5s sites=%-4d %s' %
                  (view, name, sites,
                   '  '.join('%s=%d' % (k, v) for k, v in sorted(c.items()))))
            for verdict, k, ca, cb, cg in moved:
                if verdict != 'TOWARD' or showall:
                    print('      %-12s %s %s %s' % (verdict, k[0], k[1], k[2]))
                    print('          golden  %s' % dict(cg))
                    print('          pristine%s' % dict(ca))
                    print('          patched %s' % dict(cb))
        # the COPY-COUNT projection the law must not touch
        cc = collections.Counter()
        for k in sorted(set(gc) | set(ac) | set(bc)):
            if ac[k] == bc[k]:
                cc['count-unchanged'] += 1
            elif bc[k] == gc[k]:
                cc['count-TOWARD'] += 1
            elif ac[k] == gc[k]:
                cc['count-AWAY'] += 1
            else:
                cc['count-MOVED-WRONG'] += 1
        print('%-5s %-5s %s' % (view, 'CNT',
                                '  '.join('%s=%d' % (k, v)
                                          for k, v in sorted(cc.items()))))


main()
