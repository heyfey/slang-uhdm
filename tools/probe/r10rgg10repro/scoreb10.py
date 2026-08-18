#!/usr/bin/env python3
"""r10rgg10/scoreb10.py — GRID B table: golden's C= class per (home, type,
value, read), and ours-vs-golden per cell."""
import os, sys, collections
O = sys.argv[1] if len(sys.argv) > 1 else '/tmp/r10rgg10_gridbout'

def load(p):
    d = {}
    if not os.path.exists(p): return d
    for l in open(p):
        k, _, v = l.rstrip('\n').partition('\t')
        d[k] = v
    return d

def cls(c):
    if c.startswith('logic_typespec/LOCLESS'): return 'BARE-LOGIC'
    if c.startswith('bit_typespec'): return 'DECL-BIT'
    if c.startswith('int_typespec'): return 'DECL-INT'
    if c.startswith('logic_typespec/LOC'): return 'DECL-LOGIC'
    return c

rows = []
for f in sorted(os.listdir(O)):
    if not f.endswith('.gold'): continue
    n = f[:-5]
    g = load(os.path.join(O, f)); o = load(os.path.join(O, n + '.ours'))
    for k, v in g.items():
        if not k.endswith('|IV') or not k.startswith('ELAB'): continue
        c = v.split(' C=')[1].split(' RHS=')[0]
        rows.append((n, k, cls(c), v, o.get(k, '<MISSING>')))

tab = collections.defaultdict(set)
for n, k, c, v, ov in rows:
    home, typ, val, read = n.split('__')
    tab[(home, typ, val, read)].add(c)
print('%-11s %-8s %-5s %-10s %s' % ('HOME', 'TYPE', 'VAL', 'READ', 'GOLDEN C class'))
for k in sorted(tab):
    print('%-11s %-8s %-5s %-10s %s' % (k + ('/'.join(sorted(tab[k])),)))
print()
d = [r for r in rows if r[3] != r[4]]
print('cells measured=%d   ours!=golden rows=%d' % (len(rows), len(d)))
for r in d:
    print('  %-40s\n     G: %s\n     O: %s' % (r[0], r[3], r[4]))
