#!/usr/bin/env python3
"""r10earl85 — classify the corpus census `cen85.sh` produced.

MEASUREMENT ONLY.  Rows are joined per DATABASE as a MULTISET on the KEY
(keys collide -- two ELABORATED copies of one declaration live at the same
span -- so a last-writer dict would drop rows).  Every joined cell lands in
exactly one bucket, and the two families this pass owns are counted
separately:

  FAMILY-OPKEPT   golden's ELAB `param_assign` Rhs is an OPERATION where ours
                  folded it to a CONSTANT  (§ srlgUnsizedBasedShiftBail85)
  FAMILY-OVSTAMP  golden and ours disagree on `vpiOverriden` and on NOTHING
                  else                     (§ paOvFoldedRangeNoStamp85)
  OTHER-DIFF      any other payload disagreement
  BOTH-SAME       payload identical

usage: cencount85.py <prefix>.cells
"""
import sys, collections

per = collections.defaultdict(lambda: collections.defaultdict(lambda: ([], [])))
for line in open(sys.argv[1], errors='replace'):
    line = line.rstrip('\n')
    if '\t' not in line or '|' not in line: continue
    side, db, row = line.split('\t', 2)
    k, v = row.split('|', 1)
    per[db][k.strip()][0 if side == 'G' else 1].append(v.strip())

b = collections.Counter()
opkept = []
ovstamp = []
for db, keys in per.items():
    for k, (gl, ol) in keys.items():
        gl.sort(); ol.sort()
        n = max(len(gl), len(ol))
        for i in range(n):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            if gv is None: b['ONLY-OURS'] += 1; continue
            if ov is None: b['ONLY-GOLDEN'] += 1; continue
            if gv == ov: b['BOTH-SAME'] += 1; continue
            gf = dict(x.split('=', 1) for x in gv.split() if '=' in x)
            of = dict(x.split('=', 1) for x in ov.split() if '=' in x)
            elab = 'VIEW=ELAB' in k
            if elab and gf.get('RK') == 'operation' and of.get('RK') == 'constant':
                b['FAMILY-OPKEPT'] += 1; opkept.append((db, k)); continue
            diff = [f for f in set(gf) | set(of) if gf.get(f) != of.get(f)]
            if elab and diff == ['OV']:
                b['FAMILY-OVSTAMP'] += 1; ovstamp.append((db, k)); continue
            b['OTHER-DIFF'] += 1
print('databases joined: %d' % len(per))
for name in ('BOTH-SAME','FAMILY-OPKEPT','FAMILY-OVSTAMP','OTHER-DIFF','ONLY-GOLDEN','ONLY-OURS'):
    print('%-16s %d' % (name, b[name]))
print()
print('-- FAMILY-OPKEPT cells (golden keeps the operation, we fold):')
for db, k in sorted(opkept): print('   %-46s %s' % (db, k))
print('-- FAMILY-OVSTAMP cells (vpiOverriden the ONLY disagreement):')
for db, k in sorted(ovstamp): print('   %-46s %s' % (db, k))
