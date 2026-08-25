#!/usr/bin/env python3
"""r10earl88 - score the sig88 census, golden vs ours, as a MULTISET JOIN
(RESUME sec 9: keys collide, a last-writer dict drops rows).

KEY     = db | ownerkind | owner | signame
PAYLOAD = container | kind | ELEM= | TS= | DIR=

Buckets:
  BOTH-SAME            key present both sides, payloads equal
  FAM-NET2VAR          golden VAR/packed_array_var, ours NET/packed_array_net
  OTHER-CONTAINER      container differs, not the family
  DIFF-KIND            same container, different object kind
  DIFF-PAYLOAD         same container+kind, elem/ts/dir differ
  ONLY-GOLDEN          key only golden has  (a var ADDED where golden has none
  ONLY-OURS            key only we have      is AWAY; both sets are scored)
Also GATE-REACHABLE (measured on OUR OWN rows, WITHOUT asking whether the row
already agrees - earl66's lesson) = every packed_array_net whose first Element
is a struct_net, i.e. every row the law can reach at all.
"""
import sys, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    for line in open(p):
        line = line.rstrip('\n')
        f = line.split('|')
        if len(f) < 9: continue
        key = '|'.join(f[0:4])
        pay = '|'.join(f[4:])
        d[key][pay] += 1
    return d

g = load(sys.argv[1]); o = load(sys.argv[2])
out = open(sys.argv[3], 'w') if len(sys.argv) > 3 else sys.stdout
b = collections.Counter()
fam, onlyg, onlyo, other, dk, dp = [], [], [], [], [], []
for key in set(g) | set(o):
    gc, oc = g.get(key, collections.Counter()), o.get(key, collections.Counter())
    same = gc & oc
    b['BOTH-SAME'] += sum(same.values())
    gr, orr = gc - same, oc - same
    if not gr and not orr: continue
    gl = list(gr.elements()); ol = list(orr.elements())
    for i in range(max(len(gl), len(ol))):
        gp = gl[i] if i < len(gl) else None
        op = ol[i] if i < len(ol) else None
        if gp is None:
            b['ONLY-OURS'] += 1; onlyo.append((key, op)); continue
        if op is None:
            b['ONLY-GOLDEN'] += 1; onlyg.append((key, gp)); continue
        gf, of = gp.split('|'), op.split('|')
        if gf[0] != of[0]:
            if gf[0] == 'VAR' and of[0] == 'NET' and gf[1] == 'packed_array_var' \
               and of[1] == 'packed_array_net':
                b['FAM-NET2VAR'] += 1; fam.append((key, gp, op))
            else:
                b['OTHER-CONTAINER'] += 1; other.append((key, gp, op))
        elif gf[1] != of[1]:
            b['DIFF-KIND'] += 1; dk.append((key, gp, op))
        else:
            b['DIFF-PAYLOAD'] += 1; dp.append((key, gp, op))
reach = 0
for key, c in o.items():
    for pay, n in c.items():
        f = pay.split('|')
        if f[1] == 'packed_array_net' and f[2] == 'ELEM=struct_net':
            reach += n
print('== BUCKETS ==', file=out)
for k in ['BOTH-SAME','FAM-NET2VAR','OTHER-CONTAINER','DIFF-KIND','DIFF-PAYLOAD',
          'ONLY-GOLDEN','ONLY-OURS']:
    print('%-18s %8d' % (k, b[k]), file=out)
print('%-18s %8d   (ours: packed_array_net with a struct_net element)'
      % ('GATE-REACHABLE', reach), file=out)
for name, rows in (('FAM-NET2VAR', fam), ('OTHER-CONTAINER', other),
                   ('DIFF-KIND', dk), ('DIFF-PAYLOAD', dp)):
    print('\n== %s (%d) ==' % (name, len(rows)), file=out)
    for r in sorted(rows)[:400]:
        print('  G[%s] O[%s]  %s' % (r[1], r[2], r[0]), file=out)
for name, rows in (('ONLY-GOLDEN', onlyg), ('ONLY-OURS', onlyo)):
    print('\n== %s (%d) ==' % (name, len(rows)), file=out)
    for r in sorted(rows)[:200]:
        print('  [%s]  %s' % (r[1], r[0]), file=out)
