#!/usr/bin/env python3
# r10uvm119repro/pred119.py — THE A-PRIORI MOVER PREDICTION.  MEASUREMENT ONLY.
#
#   pred119.py <cen-dir>
#
# Written from PRISTINE databases alone (no patched binary is built, read or
# consulted): a cell is predicted to MOVE when golden's hier_path carries a
# `randomize` step and a `vpiWith=constraint`, i.e. golden took Surelog's
# `paRandomize_call` branch, while ours names the same path `<recv>.randomize`.
# Everything else in the census is predicted UNTOUCHED, and the two
# member-form-WITHOUT-with residues (the path END span and the argument's
# dump-synthesised fullname) are named so that they cannot later be mistaken
# for movers.
import sys, os, re, collections

d = sys.argv[1]
cells = sorted({f.split('.', 2)[2].rsplit('.txt', 1)[0]
                for f in os.listdir(d) if f.startswith('cen.g.')})
tot = collections.Counter()
for c in cells:
    G = [l.rstrip('\n').split('\t') for l in open('%s/cen.g.%s.txt' % (d, c))]
    O = [l.rstrip('\n').split('\t') for l in open('%s/cen.o.%s.txt' % (d, c))]
    ok = collections.defaultdict(list)
    for r in O:
        if len(r) >= 4: ok[(r[0], r[2])].append(r[3])
    move, why = [], collections.Counter()
    for r in G:
        if len(r) < 4 or r[0] != 'HP': continue
        gv = r[3]
        if 'vpiWith=constraint' not in gv: continue     # not the with-form
        mine = ok.get((r[0], r[2]), [])
        if not mine: 
            why['GOLD-ONLY-PATH'] += 1; move.append((r[2], gv, '<absent>')); continue
        for ov in mine:
            if ov != gv:
                move.append((r[2], gv, ov)); why['NAME/SPAN/WITH'] += 1
    print('== %s : PREDICTED MOVERS = %d  %s' % (c, len(move), dict(why)))
    for k, gv, ov in move:
        gn = re.match(r'hier_path\(([^)]*)\)', gv)
        on = re.match(r'hier_path\(([^)]*)\)', ov) if ov != '<absent>' else None
        print('   %-62s  golden=%-22s ours=%s' % (k, gn.group(1) if gn else '?',
                                                  on.group(1) if on else ov))
    tot[c] = len(move)
print()
print('TOTAL PREDICTED MOVING PATHS = %d over %d cells' % (sum(tot.values()), len(cells)))
