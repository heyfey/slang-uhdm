#!/usr/bin/env python3
"""obdiff.py <golden.uhdm> <on.uhdm> <off.uhdm>: order-blind uhdm-dump line multisets (ids and paths stripped):
the lines ON holds that OFF does not and vice versa, each with golden's count of that line, and the distances
|golden - on|, |golden - off|.  A line ON gains that golden lacks (more than golden's count) moves AWAY."""
import os, re, sys, subprocess, collections
DUMP = os.environ['UHDM_DUMP']
def dump(f):
    t = subprocess.run([DUMP, f], capture_output=True, text=True, errors='replace').stdout
    return collections.Counter(re.sub(r'id:\d+', '', re.sub(r'/[^ ,:()]*/', '', l)).strip() for l in t.splitlines()
                               if 'Restored design' not in l)
g, a, b = (dump(x) for x in sys.argv[1:4])
def dist(x, y): return sum(((x - y) + (y - x)).values())
print(f'dist golden-on={dist(g, a)} golden-off={dist(g, b)}')
for l in sorted(set(a) | set(b)):
    if a[l] != b[l]: print(f'  on={a[l]} off={b[l]} gold={g[l]}  {l}')
