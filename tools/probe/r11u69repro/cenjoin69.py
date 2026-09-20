#!/usr/bin/env python3
"""r11u69 census JOIN — the gen-scope cont_assign cells where golden's Rhs is a
CONSTANT and ours is not (the law's candidate sites), and the reverse (cells
where we already fold and golden does not).  Keyed on (test, owner, ca-loc,
ordinal) so a multiset of identical keys is not collapsed."""
import collections
import sys

g = collections.defaultdict(list)
o = collections.defaultdict(list)
for line in open(sys.argv[1]):
    f = line.rstrip('\n').split('\t')
    if len(f) < 6:
        continue
    test, side, owner, caloc, lhs, rhs = f[0], f[1], f[2], f[3], f[4], f[5]
    (g if side == 'G' else o)[(test, owner, caloc, lhs)].append(rhs)

cand = []
rev = []
for k in sorted(set(g) | set(o)):
    gl, ol = g.get(k, []), o.get(k, [])
    for i in range(max(len(gl), len(ol))):
        gr = gl[i] if i < len(gl) else '<none>'
        orr = ol[i] if i < len(ol) else '<none>'
        if gr == orr:
            continue
        gc = gr.startswith('RHS=constant')
        oc = orr.startswith('RHS=constant')
        if gc and not oc:
            cand.append((k, gr, orr))
        elif oc and not gc:
            rev.append((k, gr, orr))

print(f'GOLDEN-FOLDS-WE-DO-NOT: {len(cand)} cells, '
      f'{len(set(c[0][0] for c in cand))} tests')
for k, gr, orr in cand:
    print(f'  {k[0]} | {k[1]} | {k[2]} | {k[3]}\n      G {gr}\n      O {orr}')
print(f'WE-FOLD-GOLDEN-DOES-NOT: {len(rev)} cells, '
      f'{len(set(c[0][0] for c in rev))} tests')
for k, gr, orr in rev:
    print(f'  {k[0]} | {k[1]} | {k[2]} | {k[3]}\n      G {gr}\n      O {orr}')
