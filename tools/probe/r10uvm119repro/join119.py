#!/usr/bin/env python3
# r10uvm116repro/join119.py -- MULTISET join of two cen119 censuses (uvm116's join, reused
# unchanged: the multiset discipline is the same and the row format is the same).
# MEASUREMENT ONLY.  LHS is ALWAYS golden.
#
#   join116.py <cen.golden.txt> <cen.ours.txt>
#
# Rows are (FORM, KEY, VALUE).  The join is a MULTISET join on (FORM,KEY):
# keys collide (the DEF and the ELAB view emit the same site twice) and a
# last-writer dict would silently drop half the population.  Output:
#   AGREE   n   -- same (FORM,KEY,VALUE) multiplicity on both sides
#   DIFFER      -- the key exists on both sides with a different VALUE
#   GOLD-ONLY   -- golden has it, we do not
#   OURS-ONLY   -- we have it, golden does not
import sys, collections

def load(p):
    c = collections.Counter()
    for line in open(p):
        f = line.rstrip('\n').split('\t')
        if len(f) < 4: continue
        c[(f[0], f[2], f[3])] += 1
    return c

g = load(sys.argv[1]); o = load(sys.argv[2])
gk = collections.defaultdict(list); ok = collections.defaultdict(list)
for (fm, k, v), n in g.items(): gk[(fm, k)].append((v, n))
for (fm, k, v), n in o.items(): ok[(fm, k)].append((v, n))
agree = differ = gonly = oonly = 0
out = []
for key in sorted(set(gk) | set(ok)):
    gv = dict(gk.get(key, [])); ov = dict(ok.get(key, []))
    if gv == ov:
        agree += sum(gv.values()); continue
    if not ov:
        gonly += sum(gv.values()); out.append('GOLD-ONLY\t%s\tG=%s' % ('|'.join(key), gv)); continue
    if not gv:
        oonly += sum(ov.values()); out.append('OURS-ONLY\t%s\tO=%s' % ('|'.join(key), ov)); continue
    differ += 1
    out.append('DIFFER\t%s\n    G= %s\n    O= %s' % ('|'.join(key), gv, ov))
for l in out: print(l)
print('-- AGREE=%d DIFFER=%d GOLD-ONLY=%d OURS-ONLY=%d' % (agree, differ, gonly, oonly))
