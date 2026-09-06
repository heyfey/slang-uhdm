#!/usr/bin/env python3
"""r10earl110 -- the grid scorer.  MEASUREMENT ONLY.

Joins three cen110 censuses (golden / pristine / patched) as a MULTISET on the
census KEY and scores every cell.  The key is <tag>|<span>|<element kind:name
vector>; the VALUE is the set of hier_path VpiNames seen at that key.  Names,
not counts, decide a verdict -- r10uvm170's residue R6 (a multiplicity that
differs between an elaborated and a definition copy must not read as a shape
change).

verdicts, per key:
  TOGOLD        pristine != golden, patched == golden
  AWAY          pristine == golden, patched != golden      <- must be 0
  MOVEDWRONG    pristine != golden, patched != golden, patched != pristine
  STILLWRONG    pristine != golden, patched == pristine
  SAME_AGREE    pristine == golden == patched
  G-ONLY/O-ONLY one-sided keys
"""
import sys, collections

def load(p):
    d = collections.defaultdict(set)
    rc = None
    for ln in open(p):
        ln = ln.rstrip('\n')
        if ln.startswith('CENRC '):
            rc = ln.split()[1]; continue
        parts = ln.split('\t')
        if len(parts) < 2: continue
        d[parts[0]].add(parts[1])
    if rc != '0':
        print("FATAL: %s CENRC=%s" % (p, rc)); sys.exit(3)
    return d

g, p, a = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
tally = collections.Counter()
rows = []
for k in sorted(set(g) | set(p) | set(a)):
    if k not in g:
        v = 'O-ONLY'
    elif k not in p and k not in a:
        v = 'G-ONLY'
    else:
        gs, ps, as_ = g.get(k, set()), p.get(k, set()), a.get(k, set())
        if ps == gs and as_ == gs: v = 'SAME_AGREE'
        elif ps != gs and as_ == gs: v = 'TOGOLD'
        elif ps == gs and as_ != gs: v = 'AWAY'
        elif as_ == ps: v = 'STILLWRONG'
        else: v = 'MOVEDWRONG'
    tally[v] += 1
    if v != 'SAME_AGREE':
        rows.append((v, k, sorted(g.get(k, [])), sorted(p.get(k, [])), sorted(a.get(k, []))))
for v, k, gs, ps, as_ in rows:
    print("%-11s %s\n    G %s\n    P %s\n    A %s" % (v, k, gs, ps, as_))
print("TALLY " + " ".join("%s=%d" % (k, tally[k]) for k in
      ['SAME_AGREE','TOGOLD','AWAY','MOVEDWRONG','STILLWRONG','G-ONLY','O-ONLY']))
