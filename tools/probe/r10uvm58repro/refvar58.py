#!/usr/bin/env python3
"""r10uvm58repro/refvar58.py — the REF_VAR census: every (name,span) key
whose VARIABLE-CLASS SET differs between golden and ours AND involves a
ref_var on either side.  Golden is ALWAYS argv[1].  Indentation is stripped
and multiplicities are counted, so a shape present twice on one side and
once on the other is a differing key.

  usage: refvar58.py <g.dump> <o.dump>
"""
import re, sys, collections
RE = re.compile(r'^\s*\\_([a-z_0-9]+): \(([^)]*)\)(, line:\d+:\d+, endln:\d+:\d+)?$')
def load(p):
    c = collections.Counter()
    for ln in open(p):
        m = RE.match(ln.rstrip('\n'))
        if not m: continue
        kind, name, span = m.group(1), m.group(2), m.group(3) or ''
        if not kind.endswith('_var'): continue
        c[(name, span, kind)] += 1
    return c
G, O = load(sys.argv[1]), load(sys.argv[2])
keys = collections.defaultdict(lambda: ({}, {}))
for (n,s,k),v in G.items(): keys[(n,s)][0][k]=v
for (n,s,k),v in O.items(): keys[(n,s)][1][k]=v
rows=[]
for (n,s),(gk,ok) in keys.items():
    if set(gk)==set(ok): continue
    if 'ref_var' not in gk and 'ref_var' not in ok: continue
    rows.append((n,s,gk,ok))
rows.sort()
print(f'{len(rows)} keys involving ref_var on either side')
for n,s,gk,ok in rows:
    print(f'  g={",".join(sorted(gk))!s:26} o={",".join(sorted(ok)) or "-":22} {n}{s}')
