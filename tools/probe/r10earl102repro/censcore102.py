#!/usr/bin/env python3
"""r10earl102 -- MEASUREMENT ONLY.  The CORPUS census scorer.

  censcore102.py <cendir-pristine> [<cendir-patched>]

<cendir> holds <mode>__<test>.gold.txt / .ours.txt written by cenrun102.sh.
Rows are DEDUPED whole lines and keyed
  (database, view, ownerkind, ownerfullname, site, signal, path)
with the COMPARE-VISIBLE payload as the value; the golden side of the patched
directory is ASSERTED byte-identical to the pristine one before anything is
scored (a census that re-derives its own reference proves nothing).

Two reports:
 1. THE POPULATION -- every `rhsts` bound row, tallied by (golden form, ours
    form).  The law's cells are golden FOLDED / ours OP; the MUST-NOT-MOVE half
    is every other pair, and both are printed with their counts.
 2. THE WHOLE CENSUS -- BOTH-SAME / FLIP / ONLY-GOLDEN / ONLY-OURS over ALL
    rows, and with a patched directory, TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG /
    MOVED-NO-GOLDEN / ADDED / REMOVED per cell.
"""
import sys, os, collections

def load(p):
    d = {}
    if not os.path.exists(p):
        return d
    for ln in open(p, errors='replace'):
        if not ln.startswith('RNG\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        if len(f) < 9:
            continue
        d[tuple(f[1:7])] = tuple(f[7:9])
    return d

def collect(cendir):
    out = {}
    for fn in sorted(os.listdir(cendir)):
        if not fn.endswith('.gold.txt'):
            continue
        db = fn[:-len('.gold.txt')]
        g = load(os.path.join(cendir, fn))
        o = load(os.path.join(cendir, db + '.ours.txt'))
        out[db] = (g, o)
    return out

pris = collect(sys.argv[1])
pat = collect(sys.argv[2]) if len(sys.argv) > 2 else None

if pat is not None:
    bad = 0
    for db in sorted(set(pris) | set(pat)):
        if db not in pris or db not in pat:
            print('GOLDEN-SET-MISMATCH', db); bad += 1; continue
        if pris[db][0] != pat[db][0]:
            print('GOLDEN-CHANGED', db); bad += 1
    print('GOLDEN-SIDE-IDENTICAL' if bad == 0 else 'GOLDEN-SIDE-DIFFERS %d' % bad)

pop = collections.Counter()
popcells = collections.defaultdict(list)
tot_same = tot_flip = tot_og = tot_oo = 0
tg = aw = sw = mw = add = rem = 0
movers = collections.Counter()
for db, (g, o) in sorted(pris.items()):
    kg, ko = set(g), set(o)
    tot_same += sum(1 for k in kg & ko if g[k] == o[k])
    flips = [k for k in kg & ko if g[k] != o[k]]
    tot_flip += len(flips)
    tot_og += len(kg - ko)
    tot_oo += len(ko - kg)
    for k in kg | ko:
        if 'rhsts' not in k[5]:
            continue
        gf = g[k][0] if k in g else 'ABSENT'
        of = o[k][0] if k in o else 'ABSENT'
        pop[(gf, of)] += 1
        if gf == 'FOLDED' and of == 'OP':
            popcells[db].append((k, g[k], o[k]))
    if pat is not None:
        p = pat[db][1]
        for k in sorted(set(g) | set(o) | set(p)):
            ov, pv, gv = o.get(k), p.get(k), g.get(k)
            if ov is None and pv is not None:
                add += 1; print('ADDED   %s %s %s' % (db, ' | '.join(k), pv))
            if ov is not None and pv is None:
                rem += 1; print('REMOVED %s %s %s' % (db, ' | '.join(k), ov))
            if ov == pv:
                continue
            movers[db] += 1
            if gv is None:
                mw += 1; print('MOVED-NO-GOLDEN %s %s\n   pris %s\n   patc %s' % (db, ' | '.join(k), ov, pv))
            elif pv == gv and ov != gv:
                tg += 1
            elif ov == gv and pv != gv:
                aw += 1; print('AWAY-GOLDEN %s %s\n   golden %s\n   pris %s\n   patc %s' % (db, ' | '.join(k), gv, ov, pv))
            else:
                sw += 1; print('STILL-WRONG %s %s\n   golden %s\n   pris %s\n   patc %s' % (db, ' | '.join(k), gv, ov, pv))

print('DATABASES %d' % len(pris))
print('WHOLE CENSUS  BOTH-SAME %d  FLIP %d  ONLY-GOLDEN %d  ONLY-OURS %d'
      % (tot_same, tot_flip, tot_og, tot_oo))
print('-- rhsts POPULATION by (golden form, ours form):')
for k, v in sorted(pop.items(), key=lambda x: -x[1]):
    print('   golden %-7s ours %-7s  %d' % (k[0], k[1], v))
print('-- THE LAW\'S CELLS (golden FOLDED / ours OP), by database:')
for db in sorted(popcells):
    print('   %-40s %d' % (db, len(popcells[db])))
    for k, gv, ov in popcells[db]:
        print('        %s\n          golden %s\n          ours   %s' % (' | '.join(k), gv, ov))
print('TOTAL LAW CELLS %d in %d databases' % (sum(len(v) for v in popcells.values()), len(popcells)))
if pat is not None:
    print('TO-GOLDEN %d  AWAY-GOLDEN %d  STILL-WRONG %d  MOVED-NO-GOLDEN %d  ADDED %d  REMOVED %d'
          % (tg, aw, sw, mw, add, rem))
    print('-- CENSUS MOVERS by database:')
    for db, n in sorted(movers.items()):
        print('   %-40s %d' % (db, n))
