#!/usr/bin/env python3
"""r10uvm79repro/ct79names.py — JOIN golden and our hier_path NAMES and report
every disagreement.

This is the AUTHORITATIVE instrument for the naming law (§ hpIdxDecompiled79):
it does not ask a text predicate whether a name "looks" decompiled, it asks
GOLDEN what the name is.

The join key is (db, line:col) and NOT the file, because OUR hier_paths carry
no VpiFile while golden's do — keying on it produced joined=8845 same=0, a
100% miss that would have read as "every name differs".  Within one database a
line:col can repeat across files, so each key holds a MULTISET of names and the
report is the multiset difference: names golden has that we do not (G-only) and
names we have that golden does not (O-only).  Nothing is dropped silently; the
totals must balance.

  usage: ct79names.py <census-with-NAMES-rows> [--per-db] [--pairs]

Input rows: `NAME<TAB>{GOLD,OURS}/<tag><TAB>file<TAB>line:col<TAB>name`.
"""
import sys, collections

path = sys.argv[1]
perdb = '--per-db' in sys.argv[2:]
pairs = '--pairs' in sys.argv[2:]
side_db_key = collections.defaultdict(collections.Counter)
rows = 0
for line in open(path, errors='replace'):
    if not line.startswith('NAME\t'):
        continue
    p = line.rstrip('\n').split('\t')
    if len(p) < 5:
        continue
    tag, lc, name = p[1], p[3], '\t'.join(p[4:])
    side, _, db = tag.partition('/')
    side_db_key[(db, lc)][(side, name)] += 1
    rows += 1

gonly = collections.Counter()   # (db, lc, name)
oonly = collections.Counter()
pairct = collections.Counter()
agree = 0
for (db, lc), c in side_db_key.items():
    g = collections.Counter({n: v for (s, n), v in c.items() if s == 'GOLD'})
    o = collections.Counter({n: v for (s, n), v in c.items() if s == 'OURS'})
    inter = g & o
    agree += sum(inter.values())
    gd, od = g - o, o - g
    for n, v in gd.items():
        gonly[(db, lc, n)] += v
    for n, v in od.items():
        oonly[(db, lc, n)] += v
    if len(gd) == 1 and len(od) == 1:
        pairct[(list(gd)[0], list(od)[0])] += min(sum(gd.values()), sum(od.values()))

print('rows=%d keys=%d agreeing=%d G_only=%d O_only=%d' %
      (rows, len(side_db_key), agree, sum(gonly.values()), sum(oonly.values())))
if perdb:
    per = collections.Counter()
    for (db, lc, n), v in oonly.items():
        per[db] += v
    for db, n in per.most_common():
        print('  db %-52s O_only=%d' % (db, n))
if pairs:
    print('-- 1:1 (golden -> ours) name pairs at the same key, by multiplicity')
    for (gn, on), n in pairct.most_common(80):
        print('  %5d  G:%s\n         O:%s' % (n, gn, on))
