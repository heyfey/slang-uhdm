#!/usr/bin/env python3
"""v11u13 verifier: param_assign census JOINED golden-vs-pristine-vs-patched.
Key = (section, Lhs parameter fullname, occurrence#).  Payload = the fields
constant::Compare reads.  Prints per-key verdict TO-GOLDEN / AWAY / SAME-WRONG.
NO DEDUP of duplicate keys (occurrence index keeps the multiset honest)."""
import sys, os, collections, importlib.util
PACEN = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                     '..', 'r11u13repro', 'pacen.py')
spec = importlib.util.spec_from_file_location("pacen", PACEN)
src = open(PACEN).read().split("for p in sys.argv")[0]
ns = {}
src = src.replace('def clip(s, n=34):', 'def clip(s, n=100000):')
exec(src, ns)
cells = ns['cells']

def keyed(p):
    seen = collections.Counter(); d = {}
    for sec, lhs, kind, dec, siz, val, ct in cells(p):
        k = (sec, lhs, seen[(sec, lhs)]); seen[(sec, lhs)] += 1
        d[k] = (kind, dec, siz, val, ct)
    return d

g, p, q = keyed(sys.argv[1]), keyed(sys.argv[2]), keyed(sys.argv[3])
to = away = samewrong = same = 0
for k in sorted(set(g) | set(p) | set(q), key=str):
    gv, pv, qv = g.get(k), p.get(k), q.get(k)
    if pv == qv:
        if gv == pv: same += 1
        else: samewrong += 1
        continue
    if qv == gv: to += 1; tag = 'TO-GOLDEN'
    elif pv == gv: away += 1; tag = 'AWAY-GOLDEN'
    else: tag = 'MOVED-WRONG'; away += 0; samewrong += 1
    print('%-11s %s\n    gold=%s\n    pris=%s\n    pat =%s' % (tag, k, gv, pv, qv))
print('TOTALS TO-GOLDEN=%d AWAY-GOLDEN=%d UNCHANGED-EQUAL=%d UNCHANGED-OR-MOVED-WRONG=%d' % (to, away, same, samewrong))
