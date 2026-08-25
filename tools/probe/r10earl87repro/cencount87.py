#!/usr/bin/env python3
"""r10earl87 — classify the corpus census `cen87.sh` produced.

MEASUREMENT ONLY (the official uhdm-cmp is the judge).  Rows are joined per
DATABASE as a MULTISET on the KEY -- keys collide (two ELABORATED copies of one
declaration live at the same span) so a last-writer dict would silently DROP
rows, RESUME.md sec 9.

Buckets, in the order they are tested:

  FAMILY-SUBFOLD  the row's ONLY disagreement is the Rhs TREE, golden's tree is
                  SHORTER and holds FEWER `operation` nodes  (earl86's family)
  FAMILY-OPKEPT   golden's ELAB Rhs is an OPERATION where ours folded the whole
                  thing to a CONSTANT      (earl85's family, the residues)
  FAMILY-OVSTAMP  `vpiOverriden` is the ONLY disagreement -- THE FAMILY THIS
                  PASS OWNS (earl85's R1 / earl86's R1)
  FAMILY-IMPID    `IMP` and/or `LLP` are the only disagreements: the ELAB Lhs
                  identity of a SHADOWED parameter (golden hands the module's
                  own row the imported clone's vpiImported/vpiLocalParam)
  TREE-OTHER      the TREE is the only disagreeing field, some other way
  OTHER-DIFF      any other payload disagreement
  BOTH-SAME       payload identical

GATE-REACHABLE counts, independently of agreement, every ELAB row whose OURS
Lhs parameter carries a `vpiImported` package name -- i.e. every materialized
import copy in an elaborated instance, which is the NECESSARY condition for
this pass's law to fire.  earl66's lesson: a census keyed on the shape you
intend to CHANGE is blind to the rows you would change by ACCIDENT, so the
count is taken whether or not the row agrees with golden.
GATE-COLLIDE narrows it to the rows this pass's law would actually STAMP: an
ELAB materialized import copy whose PNAME also names a parameter that the same
elaborated instance carries an OVERRIDDEN row for.

usage: cencount87.py <prefix>.cells
"""
import sys, re, collections

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
impid = []
gate_rows = []
collide_rows = []
# THE OVERRIDDEN-NAME SET per (db, instance), read from OUR OWN rows: a name is
# "overridden here" when this instance has a NON-imported ELAB row carrying
# OV=1.  Built before the walk so GATE-COLLIDE can be counted independently of
# whether the imported row already agrees.
ovnames = collections.defaultdict(set)
for db, keys in per.items():
    for k, (gl, ol) in keys.items():
        if 'VIEW=ELAB' not in k:
            continue
        m = re.search(r'PNAME=(\S+)', k); i = re.search(r'INST=(\S+)', k)
        if not m or not i:
            continue
        for v in ol:
            f = fields(v)
            if f.get('OV') == '1' and f.get('IMP', '-') == '-':
                ovnames[(db, i.group(1))].add(m.group(1))
for db, keys in per.items():
    for k, (gl, ol) in keys.items():
        gl.sort(); ol.sort()
        n = max(len(gl), len(ol))
        for i in range(n):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            if ov is not None and 'VIEW=ELAB' in k:
                of0 = fields(ov)
                if of0.get('IMP', '-') != '-':
                    gate_rows.append((db, k))
                    mm = re.search(r'PNAME=(\S+)', k); ii = re.search(r'INST=(\S+)', k)
                    if mm and ii and mm.group(1) in ovnames[(db, ii.group(1))]:
                        collide_rows.append((db, k))
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
            if elab and diff and set(diff) <= {'IMP', 'LLP'}:
                b['FAMILY-IMPID'] += 1; impid.append((db, k)); continue
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
             'FAMILY-IMPID', 'TREE-OTHER', 'OTHER-DIFF', 'ONLY-GOLDEN', 'ONLY-OURS'):
    print('%-16s %d' % (name, b[name]))
print('%-16s %d' % ('GATE-REACHABLE', len(gate_rows)))
print('%-16s %d' % ('GATE-COLLIDE', len(collide_rows)))
print()
print('-- FAMILY-SUBFOLD cells (golden folded an operand subtree, we did not):')
for db, k in sorted(subfold): print('   %-46s %s' % (db, k))
print('-- FAMILY-OPKEPT cells (golden keeps the operation, we fold):')
for db, k in sorted(opkept): print('   %-46s %s' % (db, k))
print('-- FAMILY-OVSTAMP cells:')
for db, k in sorted(ovstamp): print('   %-46s %s' % (db, k))
print('-- FAMILY-IMPID cells (IMP/LLP only -- the shadowed-Lhs identity residue):')
for db, k in sorted(impid): print('   %-46s %s' % (db, k))
print('-- TREE-OTHER cells:')
for db, k in sorted(treeother): print('   %-46s %s' % (db, k))
print('-- GATE-COLLIDE rows (ELAB import copy whose name is overridden here):')
for db, k in sorted(set(collide_rows)): print('   %-46s %s' % (db, k))
