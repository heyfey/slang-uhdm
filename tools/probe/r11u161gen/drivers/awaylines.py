#!/usr/bin/env python3
"""awaylines.py <golden.uhdm> <A.uhdm> <B.uhdm> [N]: order-blind (multiset) uhdm-dump lines, paths normalised.
Prints fixed = lines of A absent from golden that B no longer has, new = lines of B absent from golden that A did
not have (a law's AWAY lines), and the N most frequent new lines (the faces the change left or made)."""
import sys, os, re, subprocess, collections
D = os.environ['UHDM_DUMP']
def dump(p):
    t = subprocess.run([D, p], capture_output=True, text=True, errors='replace').stdout.splitlines()[1:]
    d = os.path.dirname(p)
    return collections.Counter(re.sub(r'/tmp/[^ ,:)]*/', '', l) for l in t)
g, a, b = (dump(p) for p in sys.argv[1:4]); N = int(sys.argv[4]) if len(sys.argv) > 4 else 15
abad = a - g; bbad = b - g
fixed = abad - bbad; new = bbad - abad
print('bad_A', sum(abad.values()), 'bad_B', sum(bbad.values()), 'fixed', sum(fixed.values()), 'new', sum(new.values()))
for l, n in new.most_common(N): print('  NEW', n, l.strip()[:150])
for l, n in fixed.most_common(N): print('  FIXED', n, l.strip()[:150])
