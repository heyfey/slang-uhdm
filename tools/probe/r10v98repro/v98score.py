#!/usr/bin/env python3
"""Three-way score: golden vs pristine vs patched, per site (multiset)."""
import sys, os, collections, signal
try:
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
except Exception:
    pass
sys.path.insert(0, '/tmp')
from importlib.machinery import SourceFileLoader
cen = SourceFileLoader('cen', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'v98cen.py')).load_module()
nospan = '--nospan' in sys.argv
args = [x for x in sys.argv[1:] if not x.startswith('--')]
tag, g, p, q = args[0], args[1], args[2], args[3]
G, P, Q = (cen.rows(x, nospan) for x in (g, p, q))
tot = collections.Counter(); det = []
for k in sorted(set(G) | set(P) | set(Q)):
    a, b, c = sorted(G.get(k, [])), sorted(P.get(k, [])), sorted(Q.get(k, []))
    if b == a and c == a: v = 'OK'
    elif b != a and c == a: v = 'FIXED'
    elif b == a and c != a: v = 'BROKE'
    elif b == c: v = 'STILL'
    else: v = 'CHANGED-STILL'
    tot[v] += 1
    if v != 'OK':
        det.append('    %-13s %s\n        G=%s\n        P=%s\n        Q=%s' % (v, k, a, b, c))
print('  %-26s cells %4d OK %4d FIXED %3d BROKE %3d STILL %4d CHANGED-STILL %3d' %
      (tag, sum(tot.values()), tot['OK'], tot['FIXED'], tot['BROKE'], tot['STILL'], tot['CHANGED-STILL']))
for d in det:
    print(d)
