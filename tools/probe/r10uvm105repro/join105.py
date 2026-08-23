#!/usr/bin/env python3
# r10uvm105repro/join105.py — MULTISET join of two r10uvm105cen censuses.
# MEASUREMENT ONLY.  LHS is ALWAYS golden, RHS is ALWAYS ours.
#
#   join105.py <golden.tsv> <ours.tsv> [--filter SUBSTR] [--only-diff]
#
# Key   = SITE, VIEW, OOB, CLS, OWNER, LC     (never the file: our expression
#         nodes carry an EMPTY VpiFile)
# Value = TSKIND, TSNAME, TSINSTANCE          (the judge-visible payload; the
#         typespec's OWN span is CARRIED by the census but kept OUT of the join
#         key -- no generated Compare reads a span, RESUME §9)
# A last-writer dict would DROP rows whose keys collide (RESUME §9), so both
# sides are Counters over (key, value) and the report is a multiset difference.
import sys, collections

def load(p):
    rows = []
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 12: continue
        rows.append((tuple(f[1:7]), tuple(f[8:11])))
    return rows

g = load(sys.argv[1]); o = load(sys.argv[2])
filt = None; onlydiff = False
a = sys.argv[3:]
while a:
    if a[0] == '--filter': filt = a[1]; a = a[2:]
    elif a[0] == '--only-diff': onlydiff = True; a = a[1:]
    else: a = a[1:]
if filt:
    g = [r for r in g if filt in '\t'.join(r[0]) + '\t'.join(r[1])]
    o = [r for r in o if filt in '\t'.join(r[0]) + '\t'.join(r[1])]

same = 0
gmap = collections.defaultdict(collections.Counter)
omap = collections.defaultdict(collections.Counter)
for k, v in g: gmap[k][v] += 1
for k, v in o: omap[k][v] += 1
rows = []
for k in set(gmap) | set(omap):
    gc = gmap.get(k, collections.Counter()); oc = omap.get(k, collections.Counter())
    inter = gc & oc
    same += sum(inter.values())
    gx = gc - inter; ox = oc - inter
    if not gx and not ox: continue
    for v, n in gx.items():
        rows.append(('G', k, v, n))
    for v, n in ox.items():
        rows.append(('O', k, v, n))
print("SAME_CELLS\t%d" % same)
print("KEYS_GOLDEN\t%d\tKEYS_OURS\t%d" % (len(gmap), len(omap)))
print("DIFF_ROWS\t%d" % len(rows))
for side, k, v, n in sorted(rows, key=lambda r: (r[1], r[0])):
    print("%s\t%s\t%s\tx%d" % (side, '\t'.join(k), '\t'.join(v), n))
