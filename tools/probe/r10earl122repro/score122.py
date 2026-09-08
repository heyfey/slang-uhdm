#!/usr/bin/env python3
"""r10earl122 — THE THREE-WAY JOIN: golden vs PRISTINE vs PATCHED, cell by cell.

MEASUREMENT ONLY.  The official `uhdm-cmp` / `scripts/verify_golden.py` are the
sole acceptance judges; this file scores a census, never a row.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

CALIBRATION FIRST (RESUME.md §9): the GOLDEN halves of the two sweeps must be
identical.  If they are not, the two sweeps did not build the same goldens and
nothing below can be attributed — this script REFUSES to score.

Scores, per cell key (home scope | ref name | span | position chain):
  TO-GOLDEN    pristine disagrees with golden, patched agrees      (the law)
  AWAY-GOLDEN  pristine agrees with golden, patched disagrees      (MUST be 0)
  MOVED-WRONG  both disagree with golden but differently           (MUST be 0)
  NOGOLD_MOVED the key has no golden counterpart and still moved   (MUST be 0)
  SAME_AGREE   unchanged and correct
  STILL-WRONG  unchanged and wrong (another law's residue)

usage: score122.py <pristine.cells> <patched.cells> [--rows]
"""
import collections
import sys


def load(path):
    """side -> {(test, mode, key): Counter(payload)}"""
    d = {'G': collections.defaultdict(collections.Counter),
         'O': collections.defaultdict(collections.Counter)}
    with open(path) as f:
        for ln in f:
            parts = ln.rstrip('\n').split('\t')
            if len(parts) != 5:
                continue
            side, test, mode, key, payload = parts
            d[side][(test, mode, key)][payload] += 1
    return d


def main():
    pris, pat = load(sys.argv[1]), load(sys.argv[2])
    rows = '--rows' in sys.argv[3:]

    if pris['G'] != pat['G']:
        only_p = set(pris['G']) - set(pat['G'])
        only_x = set(pat['G']) - set(pris['G'])
        diff = [k for k in set(pris['G']) & set(pat['G'])
                if pris['G'][k] != pat['G'][k]]
        print('CALIBRATION FAILED: the two sweeps\' GOLDEN halves differ '
              '(onlyP=%d onlyX=%d payload=%d) — nothing can be attributed'
              % (len(only_p), len(only_x), len(diff)))
        for k in list(only_p)[:5] + list(only_x)[:5] + diff[:5]:
            print('   ', k)
        return 2
    print('CALIBRATION OK: golden halves identical, %d keys' % len(pris['G']))

    G, P, X = pris['G'], pris['O'], pat['O']
    tally = collections.Counter()
    byrow = collections.defaultdict(collections.Counter)
    for k in set(P) | set(X):
        p, x = P.get(k), X.get(k)
        g = G.get(k)
        row = (k[0], k[1])
        if g is None:
            if p != x:
                tally['NOGOLD_MOVED'] += 1
                byrow[row]['NOGOLD_MOVED'] += 1
                if rows:
                    print('NOGOLD_MOVED', k, p, '->', x)
            continue
        if p == x:
            tally['SAME_AGREE' if p == g else 'STILL-WRONG'] += 1
            byrow[row]['SAME_AGREE' if p == g else 'STILL-WRONG'] += 1
            continue
        if p != g and x == g:
            tally['TO-GOLDEN'] += 1
            byrow[row]['TO-GOLDEN'] += 1
            if rows:
                print('TO-GOLDEN', k, p, '->', x)
        elif p == g and x != g:
            tally['AWAY-GOLDEN'] += 1
            byrow[row]['AWAY-GOLDEN'] += 1
            print('AWAY-GOLDEN', k, p, '->', x, '  golden:', g)
        else:
            tally['MOVED-WRONG'] += 1
            byrow[row]['MOVED-WRONG'] += 1
            print('MOVED-WRONG', k, p, '->', x, '  golden:', g)
    for name in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG', 'NOGOLD_MOVED',
                 'SAME_AGREE', 'STILL-WRONG'):
        print('%-14s %d' % (name, tally[name]))
    print('MOVER ROWS:')
    for row, c in sorted(byrow.items()):
        moved = {k: v for k, v in c.items()
                 if k in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
                          'NOGOLD_MOVED')}
        if moved:
            print('   %-14s %-10s %s' % (row[1], row[0], moved))
    return 0


if __name__ == '__main__':
    sys.exit(main())
