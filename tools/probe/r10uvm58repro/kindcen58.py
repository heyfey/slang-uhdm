#!/usr/bin/env python3
"""r10uvm58repro/kindcen58.py — KIND CENSUS keyed on (name, span): where does golden say one
variable class and ours another?  Indentation is STRIPPED (an object is not a
dump occurrence) and each (kind,name,span) key is counted, so a shift in
multiplicity is visible too.

  usage: kindcen58.py <g.dump> <o.dump> [filter-substring]

Both dumps must already have uhdm-dump's first line (the DB path) stripped.
GUARD: a key present on one side only prints with a 0 on the other; nothing is
silently dropped.  Only *_var / io_decl / *_typespec heads are considered.
"""
import re, sys, collections
g, o = sys.argv[1], sys.argv[2]
filt = sys.argv[3] if len(sys.argv) > 3 else ''
RE = re.compile(r'^\s*\\_([a-z_0-9]+): \(([^)]*)\)(, line:\d+:\d+, endln:\d+:\d+)?$')
def load(p):
    c = collections.Counter()
    for ln in open(p):
        m = RE.match(ln.rstrip('\n'))
        if not m: continue
        kind, name, span = m.group(1), m.group(2), m.group(3) or ''
        if not kind.endswith('_var') and kind != 'io_decl': continue
        c[(name, span, kind)] += 1
    return c
G, O = load(g), load(o)
keys = collections.defaultdict(dict)
for (n, s, k), v in G.items(): keys[(n, s)].setdefault('g', {})[k] = v
for (n, s, k), v in O.items(): keys[(n, s)].setdefault('o', {})[k] = v
rows = []
for (n, s), d in keys.items():
    if filt and filt not in n: continue
    gk = d.get('g', {}); ok = d.get('o', {})
    if set(gk) == set(ok): continue
    rows.append((n, s, gk, ok))
rows.sort()
print(f'{len(rows)} (name,span) keys where the VARIABLE CLASS SET differs')
byshape = collections.Counter()
for n, s, gk, ok in rows:
    byshape[(','.join(sorted(gk)), ','.join(sorted(ok)))] += 1
for (a, b), c in byshape.most_common():
    print(f'  golden[{a or "-"}] vs ours[{b or "-"}]  : {c} keys')
print()
for n, s, gk, ok in rows[:400]:
    print(f'  {n}{s}\n      g={gk} o={ok}')
