#!/usr/bin/env python3
"""r11u60 GRID SCORER — joins the golden / pristine / law shape listings of one
arm cell by cell, keyed on (listing, parameter, loc), and classifies each:
  SAME  pristine == golden  and law == golden
  TO    pristine != golden  and law == golden          (moved TO golden)
  AWAY  pristine == golden  and law != golden          (moved AWAY from golden)
  STILL pristine != golden  and law != golden          (unmoved, still wrong)
  MOVED-WRONG  pristine != golden, law != golden, law != pristine (moved, still wrong)
A key present on one side only is reported as MISSING and counted.
usage: score60.py <arm> <golden.dump> <pris.dump> <law.dump>"""
import os, sys, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))  # r11v60: was a
# hard-coded /tmp scratch path of the implementing session; the committed
# instrument must import its own shape.py wherever the repo is checked out.
from shape import parse

def cells(p):
    d = collections.defaultdict(list)
    for sect, name, loc, desc in parse(p):
        d[(sect, name, loc)].append(desc)
    return {k: sorted(v) for k, v in d.items()}

arm, g, o, l = sys.argv[1], cells(sys.argv[2]), cells(sys.argv[3]), cells(sys.argv[4])
keys = sorted(set(g) | set(o) | set(l))
tot = collections.Counter()
for k in keys:
    G, O, L = g.get(k), o.get(k), l.get(k)
    if G is None or O is None or L is None:
        tot['MISSING'] += 1
        print('  MISSING      %-16s %-28s %-14s g=%s o=%s l=%s' % (k[0], k[1], k[2], G, O, L))
        continue
    if O == G and L == G:   tot['SAME'] += 1; continue
    if O != G and L == G:   v = 'TO'
    elif O == G and L != G: v = 'AWAY'
    elif L == O:            v = 'STILL'
    else:                   v = 'MOVED-WRONG'
    tot[v] += 1
    if v != 'STILL':
        print('  %-12s %-16s %-28s %-14s' % (v, k[0], k[1], k[2]))
        print('       golden %s' % G)
        print('       pris   %s' % O)
        print('       law    %s' % L)
    else:
        print('  STILL        %-16s %-28s %-14s golden=%s ours=%s' % (k[0], k[1], k[2], G, O))
print('ARM %-4s TO %-3d AWAY %-3d MOVED-WRONG %-3d STILL %-3d SAME %-3d MISSING %d'
      % (arm, tot['TO'], tot['AWAY'], tot['MOVED-WRONG'], tot['STILL'], tot['SAME'], tot['MISSING']))
