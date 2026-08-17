#!/usr/bin/env python3
"""r10buvm10 — THE ALIAS DELTA between two r10buvm10cen runs of the SAME corpus
row with two different binaries, on the same ID-blind edge key aljoin10.py uses.

  usage: aldelta10.py <a.cen> <tagA> <b.cen> <tagB>

Prints one line per edge key whose alias answer CHANGED (`N->A`, `A->N`, `-->A`,
...).  A brand-new `-->N` edge whose chain is `<kind>(<name>)` with no further
ancestors is the Typedef_alias REF ITSELF becoming visible to the instrument —
an artefact of the alias existing, not a second mover.
"""
import re, sys, collections

def load(path, tag):
    d = collections.defaultdict(lambda: [0, 0])
    for line in open(path):
        if not line.startswith('REF ' + tag + ' '):
            continue
        m = re.match(r'REF \S+ ts=(\S+) hasalias=(\d) ref=(\S+) reffull=(\S+) chain=(.*)$',
                     line.rstrip('\n'))
        if not m:
            continue
        ts, ha, rid, rfull, chain = m.groups()
        d[(re.sub(r':#\d+$', '', ts), re.sub(r'#\d+', '', rfull),
           re.sub(r'#\d+', '', chain))][int(ha)] += 1
    return d

A, B = load(sys.argv[1], sys.argv[2]), load(sys.argv[3], sys.argv[4])
lbl = lambda v: 'A' if v[1] else ('N' if v[0] else '-')
n = 0
for k in sorted(set(A) | set(B)):
    a, b = A.get(k, [0, 0]), B.get(k, [0, 0])
    if lbl(a) != lbl(b):
        print("%s->%s  %-42s ref=%-44s chain=%s" % (lbl(a), lbl(b), k[0], k[1], k[2][:120]))
        n += 1
print("-- %d edge-keys changed" % n)
