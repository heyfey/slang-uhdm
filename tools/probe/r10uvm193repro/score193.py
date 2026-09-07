#!/usr/bin/env python3
"""r10uvm193 — score a THREE-WAY census join (golden, pristine, patched).

MEASUREMENT ONLY.  `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
LHS is ALWAYS golden (Surelog); the other two are ours.

    score193.py <cen.g.txt> <cen.a.txt> <cen.b.txt> [-v] [--noface]
      cen.g = golden      cen.a = PRISTINE ours      cen.b = PATCHED ours

Each census line is `KEY || VALUE ;; VALUE ...` (a MULTISET of values per key,
because a wildcard-import clone is listed twice under one root and a dict
keyed on position alone silently drops the second copy — RESUME §9).

COLUMNS, one per key, all six reported so a move between two WRONG shapes
cannot hide behind a three-valued verdict:

  UNTOUCHED     pristine == patched (whatever golden says)
  TOWARD        pristine != golden, patched == golden          (the law's win)
  AWAY          pristine == golden, patched != golden          (a REGRESSION)
  MOVED-WRONG   pristine != patched, and NEITHER equals golden (a REGRESSION)
  ONLY-GOLDEN   the key exists in golden and in neither of ours
  ONLY-OURS     the key exists in ours and not in golden
  ONLY-OURS-MOVED  an ONLY-OURS key whose value changed (a REGRESSION)

Run it GOLDEN-vs-GOLDEN-vs-GOLDEN first: every column but UNTOUCHED /
ONLY-GOLDEN must be 0, or the key is wrong before any law is scored.
"""
import sys
from collections import Counter


def load(path, noface=False):
    """`--noface` drops the FACE column (field 2) from the key.

    The FACE column is a SHAPE fact, not a binding fact: golden renders a
    `foreach` index inside a `new[...]` path as the base of a `bit_select`
    (SELBASE) and we render it as a later `Path_elems` entry (HPINNER), a
    difference that predates this pass entirely.  With the face in the key
    those two rows do not join and a reference whose ACTUAL moved to exactly
    golden's object is scored ONLY-OURS-MOVED.  Re-scoring face-blind is what
    tells a real regression from a shape residue — run BOTH and report both.
    """
    d = {}
    with open(path) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line or line.startswith('--'):
                continue
            if '||' not in line:
                continue
            k, v = line.split('||', 1)
            if noface:
                fs = k.split('|')
                if len(fs) > 3:
                    k = '|'.join(fs[:2] + fs[3:])
            k = k.strip()
            vals = tuple(sorted(x.strip() for x in v.split(';;')))
            d.setdefault(k, ())
            d[k] = tuple(sorted(d[k] + vals))
    return d


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 2
    noface = '--noface' in sys.argv[4:]
    g, a, b = (load(p, noface) for p in sys.argv[1:4])
    verbose = '-v' in sys.argv[4:]
    cnt = Counter()
    detail = {c: [] for c in ('TOWARD', 'AWAY', 'MOVED-WRONG', 'STILL-WRONG',
                              'ONLY-OURS-MOVED', 'ONLY-GOLDEN', 'ONLY-OURS')}
    for k in set(a) | set(b) | set(g):
        va, vb, vg = a.get(k), b.get(k), g.get(k)
        if vg is None:
            if va is None and vb is None:
                continue
            cnt['ONLY-OURS'] += 1
            if va != vb:
                cnt['ONLY-OURS-MOVED'] += 1
                detail['ONLY-OURS-MOVED'].append((k, va, vb, vg))
            continue
        if va is None and vb is None:
            cnt['ONLY-GOLDEN'] += 1
            detail['ONLY-GOLDEN'].append((k, va, vb, vg))
            continue
        if va == vb:
            cnt['UNTOUCHED'] += 1
            if va != vg:
                cnt['STILL-WRONG'] += 1
                detail['STILL-WRONG'].append((k, va, vb, vg))
            continue
        if va != vg and vb == vg:
            cnt['TOWARD'] += 1
            detail['TOWARD'].append((k, va, vb, vg))
        elif va == vg and vb != vg:
            cnt['AWAY'] += 1
            detail['AWAY'].append((k, va, vb, vg))
        else:
            cnt['MOVED-WRONG'] += 1
            detail['MOVED-WRONG'].append((k, va, vb, vg))
    for c in ('UNTOUCHED', 'TOWARD', 'AWAY', 'MOVED-WRONG', 'STILL-WRONG',
              'ONLY-GOLDEN', 'ONLY-OURS', 'ONLY-OURS-MOVED'):
        print('%-16s %d' % (c, cnt[c]))
    if verbose:
        for c in ('TOWARD', 'AWAY', 'MOVED-WRONG', 'ONLY-OURS-MOVED'):
            for k, va, vb, vg in sorted(detail[c])[:60]:
                print('%s %s\n    pris=%s\n    pat =%s\n    gold=%s'
                      % (c, k, va, vb, vg))
    return 0


if __name__ == '__main__':
    sys.exit(main())
