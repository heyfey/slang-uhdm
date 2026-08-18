#!/usr/bin/env python3
"""r10rgg10/score10.py — read the grid census back and TABULATE golden's C=
(param_assign Rhs typespec) shape per cell, plus the ours-vs-golden verdict.
"""
import os, sys, collections
O = sys.argv[1] if len(sys.argv) > 1 else '/tmp/r10rgg10_gridout'
want = sys.argv[2] if len(sys.argv) > 2 else 'IV'

def load(p):
    d = {}
    if not os.path.exists(p): return d
    for l in open(p):
        k, _, v = l.rstrip('\n').partition('\t')
        d[k] = v
    return d

rows = []
for f in sorted(os.listdir(O)):
    if not f.endswith('.gold'): continue
    n = f[:-5]
    g = load(os.path.join(O, f))
    o = load(os.path.join(O, n + '.ours'))
    for k, v in g.items():
        if not k.endswith('|' + want): continue
        view = k.split('|')[0]
        if view != 'ELAB': continue
        c = v.split(' C=')[1].split(' RHS=')[0]
        p = v.split(' P=')[1].split(' C=')[0]
        ov = o.get(k, '<MISSING>')
        rows.append((n, k, p, c, v, ov, 'SAME' if ov == v else 'DIFF'))

print('cells with an ELAB %s row: %d' % (want, len(rows)))
print()
print('== GOLDEN C= shape histogram ==')
for s, c in collections.Counter(r[3] for r in rows).most_common():
    print('%5d  %s' % (c, s))
print()
print('== cells whose GOLDEN C= is a LOC-LESS logic_typespec (the head shape) ==')
for r in rows:
    if 'logic_typespec/LOCLESS' in r[3]:
        print('  %-44s P=%s C=%s' % (r[0], r[2], r[3]))
print()
print('== ours vs golden ==')
for s, c in collections.Counter(r[6] for r in rows).most_common():
    print('%5d  %s' % (c, s))
print()
print('== DIFF cells ==')
for r in rows:
    if r[6] == 'DIFF':
        print('  %-44s\n     G: %s\n     O: %s' % (r[0], r[4], r[5]))

# ---- the classification table: which AXIS flips golden's C= shape ----
print()
print('== golden C= CLASS by (scope, type, value, read) ==')
def cls(c):
    if c.startswith('logic_typespec/LOCLESS'): return 'BARE-LOGIC'
    if c.startswith('bit_typespec'): return 'DECL-BIT'
    if c.startswith('int_typespec'): return 'DECL-INT'
    return c
seen = {}
for r in rows:
    parts = r[0].split('_')
    read = parts[-1]; val = parts[-2]; typ = parts[-3]
    scope = '_'.join(parts[:-3])
    seen.setdefault((scope, typ, val, read), set()).add(cls(r[3]))
by = collections.defaultdict(set)
for k, v in seen.items():
    by[tuple(sorted(v))].add(k)
for v, ks in sorted(by.items(), key=lambda x: -len(x[1])):
    print('%-14s %4d cells' % ('/'.join(v), len(ks)))
    ax = collections.defaultdict(collections.Counter)
    for (s, t, vl, rd) in ks:
        ax['scope'][s] += 1; ax['type'][t] += 1; ax['val'][vl] += 1; ax['read'][rd] += 1
    for a in ('scope', 'type', 'val', 'read'):
        print('      %-6s %s' % (a, dict(ax[a])))
