#!/usr/bin/env python3
"""r10earl86 — classify the corpus census `cen86.sh` produced.

MEASUREMENT ONLY (the official uhdm-cmp is the judge).  Rows are joined per
DATABASE as a MULTISET on the KEY -- keys collide (two ELABORATED copies of one
declaration live at the same span) so a last-writer dict would silently DROP
rows, RESUME.md sec 9.

Buckets, in the order they are tested:

  FAMILY-SUBFOLD  the row's ONLY disagreement is the Rhs TREE, golden's tree is
                  SHORTER and holds FEWER `operation` nodes -- THE FAMILY THIS
                  PASS OWNS (golden folded an operand subtree we kept)
  FAMILY-OPKEPT   golden's ELAB Rhs is an OPERATION where ours folded the whole
                  thing to a CONSTANT      (earl85's family, the residues)
  FAMILY-OVSTAMP  `vpiOverriden` is the ONLY disagreement (earl85's R1)
  TREE-OTHER      the TREE is the only disagreeing field, some other way
  OTHER-DIFF      any other payload disagreement
  BOTH-SAME       payload identical

GATE-REACHABLE counts, independently of agreement, the rows whose OURS Rhs is an
`operation` carrying a size(-1) constant ANYWHERE in its tree: the NECESSARY
condition for `srlgUnsizedShiftBails85` to fire, i.e. the whole population this
pass's law can reach at all.  Reported per corpus so the blast radius is a
measured number and not an argument.

usage: cencount86.py <prefix>.cells
"""
import sys, collections

per = collections.defaultdict(lambda: collections.defaultdict(lambda: ([], [])))
for line in open(sys.argv[1], errors='replace'):
    line = line.rstrip('\n')
    if '\t' not in line or '|' not in line:
        continue
    side, db, row = line.split('\t', 2)
    k, v = row.split('|', 1)
    per[db][k.strip()][0 if side == 'G' else 1].append(v.strip())

def fields(v):
    return dict(x.split('=', 1) for x in v.split() if '=' in x)

def nodes(tree):
    return [] if tree in ('-', None) else tree.split(';')

b = collections.Counter()
subfold, opkept, ovstamp, treeother = [], [], [], []
gate_rows = []
for db, keys in per.items():
    for k, (gl, ol) in keys.items():
        gl.sort(); ol.sort()
        n = max(len(gl), len(ol))
        for i in range(n):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            if ov is not None:
                of0 = fields(ov)
                if of0.get('RK') == 'operation':
                    for nd in nodes(of0.get('TREE', '-')):
                        p = nd.split(':')
                        if len(p) > 3 and p[1] == 'constant' and p[3] == '-1':
                            gate_rows.append((db, k))
                            break
            if gv is None:
                b['ONLY-OURS'] += 1; continue
            if ov is None:
                b['ONLY-GOLDEN'] += 1; continue
            if gv == ov:
                b['BOTH-SAME'] += 1; continue
            gf, of = fields(gv), fields(ov)
            elab = 'VIEW=ELAB' in k
            diff = sorted(f for f in set(gf) | set(of) if gf.get(f) != of.get(f))
            if elab and gf.get('RK') == 'operation' and of.get('RK') == 'constant':
                b['FAMILY-OPKEPT'] += 1; opkept.append((db, k)); continue
            if elab and diff == ['OV']:
                b['FAMILY-OVSTAMP'] += 1; ovstamp.append((db, k)); continue
            if diff == ['TREE']:
                gn, on = nodes(gf.get('TREE', '-')), nodes(of.get('TREE', '-'))
                gk = [x.split(':')[1] if len(x.split(':')) > 1 else '?' for x in gn]
                ok = [x.split(':')[1] if len(x.split(':')) > 1 else '?' for x in on]
                # golden's tree is SHORTER and holds FEWER `operation` nodes:
                # it folded an operand subtree we kept.  (The constant count
                # can go EITHER way -- one folded constant replaces an
                # operation AND the two leaf constants under it.)
                if len(gn) < len(on) and ok.count('operation') > gk.count('operation'):
                    b['FAMILY-SUBFOLD'] += 1; subfold.append((db, k)); continue
                b['TREE-OTHER'] += 1; treeother.append((db, k)); continue
            b['OTHER-DIFF'] += 1

print('databases joined: %d' % len(per))
for name in ('BOTH-SAME', 'FAMILY-SUBFOLD', 'FAMILY-OPKEPT', 'FAMILY-OVSTAMP',
             'TREE-OTHER', 'OTHER-DIFF', 'ONLY-GOLDEN', 'ONLY-OURS'):
    print('%-16s %d' % (name, b[name]))
print('%-16s %d' % ('GATE-REACHABLE', len(gate_rows)))
print()
print('-- FAMILY-SUBFOLD cells (golden folded an operand subtree, we did not):')
for db, k in sorted(subfold): print('   %-46s %s' % (db, k))
print('-- FAMILY-OPKEPT cells (golden keeps the operation, we fold):')
for db, k in sorted(opkept): print('   %-46s %s' % (db, k))
print('-- FAMILY-OVSTAMP cells:')
for db, k in sorted(ovstamp): print('   %-46s %s' % (db, k))
print('-- TREE-OTHER cells:')
for db, k in sorted(treeother): print('   %-46s %s' % (db, k))
print('-- GATE-REACHABLE rows (ours: an operation Rhs carrying a size(-1) constant):')
for db, k in sorted(set(gate_rows)): print('   %-46s %s' % (db, k))
