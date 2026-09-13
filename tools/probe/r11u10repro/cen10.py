#!/usr/bin/env python3
"""r11u10 CENSUS — score every byte mover as TO-GOLDEN / AWAY-GOLDEN /
STILL-WRONG, against the golden the SWEEP itself used.

Usage: cen10.py <pristine-workdir>/<mode> <patched-workdir>/<mode> [row...]

For each row it builds three path-normalised, id-stripped `uhdm-dump` line
MULTISETS — golden G, pristine P, patched Q — and reports

    AGREE_P = |P & G|      lines we already had right
    AGREE_Q = |Q & G|      lines we have right after the law
    AWAY    = |(P & G) - (Q & G)|    golden-agreeing lines the law DESTROYED
    TOGOLD  = |(Q & G) - (P & G)|    golden-agreeing lines the law GAINED
    WRONG_P = |P - G| , WRONG_Q = |Q - G|   our lines golden does not have
    MISS_P  = |G - P| , MISS_Q  = |G - Q|   golden lines we do not have

A bare-dump-line multiset collides on parent labels, so this scorer is NEVER
read alone: `shape10.py` prints the operand TREE of the parameter beside it,
and the official `uhdm-cmp` head is the judge.
"""
import collections
import os
import re
import subprocess
import sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
IDRE = re.compile(r', id:\d+')


def norm(text, *strip):
    out = []
    for l in text.split('\n'):
        l = IDRE.sub('', l)
        for s in strip:
            if s:
                l = l.replace(s, '')
        out.append(l)
    return collections.Counter(out)


def dump(path, *strip):
    r = subprocess.run([DUMP, path], capture_output=True, text=True,
                       errors='replace')
    return norm(r.stdout, *strip)


def golden_of(d):
    with open(os.path.join(d, 'cmds.txt'), errors='replace') as f:
        t = f.read()
    m = re.search(r'golden cache hit ([^) \n]*)', t)
    if not m:
        return None
    g = m.group(1)
    p = os.path.join(g, 'golden.uhdm')
    if os.path.isfile(p):
        return p
    c = [x for x in os.listdir(g) if x.endswith('.uhdm')]
    return os.path.join(g, c[0]) if c else None


def main():
    pris, patch = sys.argv[1], sys.argv[2]
    want = set(sys.argv[3:])
    rows = sorted(os.listdir(patch))
    print('%-30s %8s %8s %6s %7s %8s %8s' %
          ('row', 'AGREE_P', 'AGREE_Q', 'AWAY', 'TOGOLD', 'WRONG_Q', 'MISS_Q'))
    tot_away = tot_gold = 0
    for d in rows:
        row = d.rsplit('-', 1)[0]
        if want and row not in want:
            continue
        dp, dq = os.path.join(pris, d), os.path.join(patch, d)
        if not os.path.isfile(os.path.join(dq, 'slang.uhdm')):
            continue
        gp = golden_of(dq)
        if not gp:
            print('%-30s NO-GOLDEN' % row)
            continue
        gdir = os.path.dirname(gp)
        G = dump(gp, gdir)
        P = dump(os.path.join(dp, 'slang.uhdm'), dp)
        Q = dump(os.path.join(dq, 'slang.uhdm'), dq)
        ap, aq = P & G, Q & G
        away = sum((ap - aq).values())
        gold = sum((aq - ap).values())
        tot_away += away
        tot_gold += gold
        print('%-30s %8d %8d %6d %7d %8d %8d' %
              (row, sum(ap.values()), sum(aq.values()), away, gold,
               sum((Q - G).values()), sum((G - Q).values())))
    print('TOTAL AWAY-GOLDEN=%d  TO-GOLDEN=%d' % (tot_away, tot_gold))


main()
