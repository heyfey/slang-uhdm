#!/usr/bin/env python3
# r11u319 awaysum.py <awaycv output>: totals of the order-blind and chain-keyed away census; every line with a lost or
# away record printed. Reads only awaycv.sh output.
import re, sys
L = open(sys.argv[1]).read().splitlines()
lost = ca = fa = tow = bad = 0
for l in L:
    m = re.search(r'lost=(\d+).*chain away=(\d+) toward=(\d+) flat_away=(\d+)', l)
    if not m:
        bad += 1; print('UNPARSED', l); continue
    lo, c, t, f = map(int, m.groups()); lost += lo; ca += c; tow += t; fa += f
    if lo or c or f: print('AWAY', l)
print(f'case-views={len(L)} lost={lost} chain_away={ca} flat_away={fa} toward={tow} unparsed={bad}')
