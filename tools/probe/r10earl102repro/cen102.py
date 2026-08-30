#!/usr/bin/env python3
"""r10earl102 -- MEASUREMENT ONLY.  The census multiset join.

  cen102.py <golden-census> <ours-census> [<patched-census>]

Rows are DEDUPED whole lines (the parameter is listed twice by every producer,
once under Param_assigns and once under Parameters; the two rows are identical
by construction).  The join is a MULTISET join on the identity key
  (view, ownerkind, ownerfullname, site, signal, path)
with the COMPARE-VISIBLE payload as the value.  A key present on both sides
with different payloads is a FLIP; a key present on one side only is
ONLY-GOLDEN / ONLY-OURS.  With a third file, each flip is scored TO-GOLDEN /
AWAY-GOLDEN / STILL-WRONG / MOVED-WRONG.
"""
import sys, collections

def load(p):
    d = {}
    dup = 0
    for ln in open(p):
        if not ln.startswith('RNG\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        key = tuple(f[1:7])
        val = tuple(f[7:])
        if key in d:
            if d[key] != val:
                print('KEY-COLLISION-DIFFERENT-VALUE', key, d[key], val)
            dup += 1
            continue
        d[key] = val
    return d, dup

g, gd = load(sys.argv[1])
o, od = load(sys.argv[2])
p = None
if len(sys.argv) > 3:
    p, pd = load(sys.argv[3])

kg, ko = set(g), set(o)
both = kg & ko
same = [k for k in both if g[k] == o[k]]
flip = [k for k in both if g[k] != o[k]]
onlyg = sorted(kg - ko)
onlyo = sorted(ko - kg)
print('GOLDEN keys %d (dedup dropped %d)' % (len(g), gd))
print('OURS   keys %d (dedup dropped %d)' % (len(o), od))
print('BOTH-SAME %d  FLIP %d  ONLY-GOLDEN %d  ONLY-OURS %d' %
      (len(same), len(flip), len(onlyg), len(onlyo)))
for k in sorted(flip):
    print('FLIP  %s\n      golden %s\n      ours   %s' % (' | '.join(k), g[k], o[k]))
for k in onlyg:
    print('ONLY-GOLDEN %s  %s' % (' | '.join(k), g[k]))
for k in onlyo:
    print('ONLY-OURS   %s  %s' % (' | '.join(k), o[k]))

if p is not None:
    tg = aw = sw = mw = 0
    add = rem = 0
    for k in sorted(set(g) | set(o) | set(p)):
        gv, ov, pv = g.get(k), o.get(k), p.get(k)
        if ov is None and pv is not None: add += 1; print('ADDED   %s %s' % (' | '.join(k), pv))
        if ov is not None and pv is None: rem += 1; print('REMOVED %s %s' % (' | '.join(k), ov))
        if ov == pv: continue
        if gv is None:
            mw += 1; print('MOVED-NO-GOLDEN %s\n   pris %s\n   patc %s' % (' | '.join(k), ov, pv))
        elif pv == gv and ov != gv:
            tg += 1; print('TO-GOLDEN  %s\n   golden %s\n   pris   %s\n   patc   %s' % (' | '.join(k), gv, ov, pv))
        elif ov == gv and pv != gv:
            aw += 1; print('AWAY-GOLDEN %s\n   golden %s\n   pris   %s\n   patc   %s' % (' | '.join(k), gv, ov, pv))
        else:
            sw += 1; print('STILL-WRONG %s\n   golden %s\n   pris   %s\n   patc   %s' % (' | '.join(k), gv, ov, pv))
    print('TO-GOLDEN %d  AWAY-GOLDEN %d  STILL-WRONG %d  MOVED-NO-GOLDEN %d  ADDED %d  REMOVED %d'
          % (tg, aw, sw, mw, add, rem))
