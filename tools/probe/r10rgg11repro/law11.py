#!/usr/bin/env python3
"""r10rgg11/law11.py — THE LAW UNDER TEST, stated as an identity and checked
cell by cell on BOTH sides independently:

    the ELAB port-connection actual for a bare parameter name
      ==  that parameter's own ELAB param_assign Rhs, field for field
          (VpiValue, VpiSize, VpiConstType, VpiDecompile)

Prints, per cell, GOLD-holds / OURS-holds, and the counts.  MEASUREMENT ONLY.
usage: law11.py <gridoutdir> [paramname]
"""
import os, sys, collections

O = sys.argv[1]
PN = sys.argv[2] if len(sys.argv) > 2 else 'IV'


def read(p):
    d = {}
    for ln in open(p, errors='replace'):
        if '\t' not in ln:
            continue
        k, v = ln.rstrip('\n').split('\t', 1)
        d.setdefault(k, []).append(v)
    return d


cells = sorted(set(f.rsplit('.', 1)[0] for f in os.listdir(O) if f.endswith('.gold')))
cnt = collections.Counter()
for c in cells:
    for side in ('gold', 'ours'):
        p = os.path.join(O, c + '.' + side)
        if not os.path.exists(p):
            cnt[(side, 'NOFILE')] += 1
            continue
        d = read(p)
        pa = [v for k, vs in d.items() if k.startswith('ELAB|PA|') and
              k.endswith('|' + PN) for v in vs]
        po = [v for k, vs in d.items() if k.startswith('ELAB|PORT|') and
              k.endswith('|i_value') for v in vs]
        if not pa or not po:
            cnt[(side, 'NOROW')] += 1
            print('%-46s %-5s NOROW pa=%s po=%s' % (c, side, pa, po))
            continue
        ok = pa[0] == po[0]
        cnt[(side, 'HOLDS' if ok else 'BREAKS')] += 1
        if not ok:
            print('%-46s %-5s BREAKS  PA=%-52s PORT=%s' % (c, side, pa[0], po[0]))
print('-- cells=%d' % len(cells))
for k in sorted(cnt):
    print('   %-6s %-7s %d' % (k[0], k[1], cnt[k]))
