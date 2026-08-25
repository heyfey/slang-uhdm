#!/usr/bin/env python3
"""r10earl88 - 3-way arm scorer: golden vs PRISTINE vs PATCHED.

KEY     = ownerkind | owner | signame     (the CELL IDENTITY)
PAYLOAD = container | kind | ELEM= | TS= | DIR=   (judge-visible fields only;
          NO span - earl77's lesson: a payload field left in the KEY
          manufactures phantoms, and a span-carrying payload hides flips)

Payloads are DEDUPED per key: with `--elabuhdm` the SAME database lists a
DEFINITION cell and an ELABORATED cell under one owner name on BOTH sides
(earl75 R3), so the comparison is between SETS.

  TO-GOLDEN    pristine != golden, patched == golden
  AWAY-GOLDEN  pristine == golden, patched != golden
  MOVED-WRONG  pristine != golden, patched != golden, patched != pristine
  STILL-WRONG  pristine != golden, patched == pristine
  RIGHT        pristine == golden == patched
  NOGOLD-MOVED key absent from golden but the two ours-sides differ
"""
import sys, collections

def load(p):
    d = collections.defaultdict(set)
    for line in open(p):
        f = line.rstrip('\n').split('|')
        if len(f) < 8: continue
        d['|'.join(f[0:3])].add('|'.join(f[3:]))
    return d

g, o, q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
b = collections.Counter(); rows = collections.defaultdict(list)
for k in set(g) | set(o) | set(q):
    G, O, Q = g.get(k), o.get(k), q.get(k)
    if G is None:
        if O != Q: b['NOGOLD-MOVED'] += 1; rows['NOGOLD-MOVED'].append((k, O, Q))
        continue
    if O == G and Q == G: b['RIGHT'] += 1; continue
    if O != G and Q == G: b['TO-GOLDEN'] += 1; rows['TO-GOLDEN'].append((k, O, Q))
    elif O == G and Q != G: b['AWAY-GOLDEN'] += 1; rows['AWAY-GOLDEN'].append((k, O, Q))
    elif O != Q: b['MOVED-WRONG'] += 1; rows['MOVED-WRONG'].append((k, O, Q))
    else: b['STILL-WRONG'] += 1; rows['STILL-WRONG'].append((k, O, Q))
for x in ['RIGHT','TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-WRONG','NOGOLD-MOVED']:
    print('%-13s %5d' % (x, b[x]))
for x in ['TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-WRONG','NOGOLD-MOVED']:
    if not rows[x]: continue
    print('\n-- %s --' % x)
    for k, O, Q in sorted(rows[x]):
        print('   %s\n      pris  %s\n      patch %s\n      gold  %s'
              % (k, sorted(O or []), sorted(Q or []), sorted(g.get(k) or [])))
