#!/usr/bin/env python3
"""additive.py <golden> <A.uhdm> <X.uhdm> <Y.uhdm> <L.uhdm>: record-level additivity of two landings on one
database: fixed154 = rec(A) - rec(Y... ) etc.  Prints the multiset sizes and whether
rec(L) == rec(A) - (rec(A) - rec(X)) - (rec(A) - rec(Y)) + new records (none expected)."""
import sys, subprocess, re, os, collections
SC = os.environ['STRICT_CMP']
def recs(g, o):
    L = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, errors='replace').stdout.splitlines()
    s = collections.Counter()
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L): s[(m.group(2), L[i+1].strip(), L[i+2].strip())] += 1
    return s, (L[-1] if L else '')
g, a, x, y, l = sys.argv[1:6]
ra, va = recs(g, a); rx, vx = recs(g, x); ry, vy = recs(g, y); rl, vl = recs(g, l)
f155 = ra - rx; f154 = ra - ry; n155 = rx - ra; n154 = ry - ra
pred = ra - f155 - f154 + n155 + n154
print(f'A {sum(ra.values())} ({va}) | X=155 alone {sum(rx.values())} ({vx}) | Y=154 alone {sum(ry.values())} ({vy}) | L {sum(rl.values())} ({vl})')
print(f'155 fixes {sum(f155.values())} adds {sum(n155.values())}; 154 fixes {sum(f154.values())} adds {sum(n154.values())}; overlap of fixes {sum((f155 & f154).values())}')
print('ADDITIVE' if pred == rl else f'NOT ADDITIVE: L-pred {sum((rl-pred).values())} pred-L {sum((pred-rl).values())}')
