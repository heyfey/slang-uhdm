#!/usr/bin/env python3
"""r10earl55 — THREE-WAY MOVER ATTRIBUTION, joined against GOLDEN.

census55 answers "does OUR cell equal GOLDEN's".  Running it twice (golden vs
pristine, golden vs patched) and joining the two verdicts per cell is what
separates the four outcomes that a two-way diff cannot tell apart:

  TO-GOLDEN     pristine wrong -> patched RIGHT      (what the law claims)
  AWAY-GOLDEN   pristine RIGHT -> patched wrong      (the only regression class)
  STILL-WRONG   wrong -> wrong, but CHANGED          (a reshape, not a fix)
  UNMOVED-BAD   wrong -> wrong, unchanged            (a named residue)

AWAY-GOLDEN is the number that must be ZERO.  A pass that reports only "N cells
now match" cannot see the cells it broke, and the campaign has been burned by
exactly that (r10buvm5: 22 pristine-right -> patched-wrong cells shipped inside
a "gate clean" claim).

usage: attrib55.py <census_pris.txt> <census_pat.txt>
Both files must come from `census55 <golden> <ours> --all` on the SAME golden.
"""
import re
import sys


def load(path):
    cells = {}
    cur = None
    with open(path) as f:
        for ln in f:
            m = re.match(r'^AGREE\s+(\S+)\s+(.*)$', ln)
            if m:
                cells[m.group(1)] = ('AGREE', m.group(2).strip())
                cur = None
                continue
            m = re.match(r'^DISAGREE (\S+)', ln)
            if m:
                cur = m.group(1)
                cells[cur] = ['DISAGREE', '', '']
                continue
            if cur and ln.startswith('   G '):
                cells[cur][1] = ln[5:].strip()
            elif cur and ln.startswith('   O '):
                cells[cur][2] = ln[5:].strip()
                cur = None
    return cells


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    P, Q = load(sys.argv[1]), load(sys.argv[2])
    # a key present on one side only is REPORTED, never dropped: a law that
    # deletes or renames a cell would otherwise vanish from the tally.
    only_p = sorted(set(P) - set(Q))
    only_q = sorted(set(Q) - set(P))
    tally = {'TO-GOLDEN': [], 'AWAY-GOLDEN': [], 'STILL-WRONG': [],
             'UNMOVED-BAD': [], 'UNMOVED-GOOD': 0}
    for k in sorted(set(P) & set(Q)):
        p, q = P[k], Q[k]
        pw, qw = p[0] == 'DISAGREE', q[0] == 'DISAGREE'
        if not pw and not qw:
            tally['UNMOVED-GOOD'] += 1
        elif pw and not qw:
            tally['TO-GOLDEN'].append(k)
        elif not pw and qw:
            tally['AWAY-GOLDEN'].append('%s  now %s (golden %s)' % (k, q[2], q[1]))
        else:
            (tally['STILL-WRONG'] if p[2] != q[2] else
             tally['UNMOVED-BAD']).append('%s  ours %s -> %s (golden %s)'
                                          % (k, p[2], q[2], q[1]))
    print('UNMOVED-GOOD (equal on both binaries) = %d' % tally['UNMOVED-GOOD'])
    for name in ('TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG', 'UNMOVED-BAD'):
        rows = tally[name]
        print('%s = %d' % (name, len(rows)))
        for r in rows:
            print('   %s' % r)
    print('KEY-ONLY-PRISTINE = %d  KEY-ONLY-PATCHED = %d' % (len(only_p), len(only_q)))
    for r in only_p:
        print('   only-pristine %s' % r)
    for r in only_q:
        print('   only-patched  %s' % r)
    return 0


if __name__ == '__main__':
    sys.exit(main())
