#!/usr/bin/env python3
# r10earl67 — PREDICT the cells § genLpBitSelIdxOneHopFold67 can move, from a
# cen67 census of a PRISTINE database alone (no patched binary needed).
#
# A candidate is a cell that is, all at once:
#   * ELAB section, site = a cont_assign (`CA_*`), route ending in `/idx`
#     (a bit_select INDEX),
#   * kind ref_obj,
#   * whose name is a PARAM_ASSIGN of the owner instance path's PARENT scope
#     (the ONE HOP), proved either by the ref's own `afn=` (when we bind it)
#     or by a `PA_<name>` row under the parent path (when we leave it UNBOUND,
#     which is what Earlgrey's head does).
# Call-argument routes (`/arg[`) are excluded: the gate's own fence.
# MEASUREMENT ONLY.   usage: predict67.py <cells.ex> [--list]
import sys
from collections import Counter
cells = [ln.rstrip('\n').split(' ') for ln in (sys.stdin if sys.argv[1] == '/dev/stdin' else open(sys.argv[1]))]
pa = set()
for f in cells:
    if len(f) > 3 and f[3].startswith('PA_'):
        pa.add((f[2], f[3][3:]))
out = Counter(); rows = []
for f in cells:
    if len(f) < 6 or f[1] != 'ELAB' or not f[3].startswith('CA'):
        continue
    if not f[4].endswith('/idx') or '/arg[' in f[4] or f[5] != 'ref_obj':
        continue
    nm = next((x[5:] for x in f if x.startswith('name=')), None)
    afn = next((x[4:] for x in f if x.startswith('afn=')), '-')
    owner = f[2]
    parent = owner.rsplit('.', 1)[0] if '.' in owner else None
    if not nm or not parent:
        continue
    hop = (afn == parent + '.' + nm) or ((parent, nm) in pa)
    if hop:
        out[nm] += 1
        rows.append(' '.join(f[:6]))
print('PREDICTED-MOVERS', sum(out.values()), dict(out.most_common(10)))
if len(sys.argv) > 2 and sys.argv[2] == '--list':
    for r in rows:
        print(' ', r)
