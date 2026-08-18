#!/usr/bin/env python3
"""r10buvm19repro/predict19.py — the a-priori mover prediction.

Reads a cenall19 census of a PRISTINE sweep (golden `G:` rows and our `O:`
rows) and lists every (test, mode) whose GOLDEN carries this law's shape:
an ELABPKG `foreach` header array reference with NO typespec where OURS
carries one.  It also reports the reverse (an OVER-FIRE candidate) and the
whole ELABPKG typespec-presence contingency table, so a claim that the law
is tight is a MEASUREMENT.

usage: predict19.py <census.txt>
"""
import sys, re
from collections import defaultdict

rows = defaultdict(dict)   # (side,db) -> {(key,view): (ts,act,vk,lv)}
for line in open(sys.argv[1]):
    if not line.startswith('FA '): continue
    f = line.split()
    tag = f[1]
    side, db = tag.split(':', 1)
    d = {}
    for tok in f[2:]:
        k, _, v = tok.partition('=')
        d[k] = v
    rows[(side, db)][(d['key'], d['view'])] = (d['ts'], d.get('act','-'), d['vk'], d.get('lv','-'))

dbs = sorted({db for (s, db) in rows})
gold_nots = []
movers = defaultdict(int)
over = defaultdict(int)
tab = defaultdict(int)
for db in dbs:
    G = rows.get(('G', db), {})
    O = rows.get(('O', db), {})
    for k in set(G) | set(O):
        g = G.get(k); o = O.get(k)
        if k[1] != 'ELABPKG': continue
        gt = g[0] if g else '-'
        ot = o[0] if o else '-'
        tab[(gt, ot)] += 1
        if gt == 'NONE' and ot not in ('NONE', '-'):
            movers[db] += 1
        if ot == 'NONE' and gt not in ('NONE', '-'):
            over[db] += 1
print('ELABPKG contingency  (golden ts, ours ts) -> sites')
for k, v in sorted(tab.items()): print('   ', k, v)
print()
print('PREDICTED-MOVER (golden NONE, ours has one), by database:')
for db, n in sorted(movers.items()): print('   %-52s %d' % (db, n))
print('PREDICTED-MOVER-DBS', len(movers), 'CELLS', sum(movers.values()))
print('PREDICTED-MOVER-TESTS', sorted({db.split('/')[1].rsplit('-',1)[0] for db in movers}))
print()
print('REVERSE (ours NONE, golden has one) — pre-existing over-fires:')
for db, n in sorted(over.items()): print('   %-52s %d' % (db, n))
print('REVERSE-DBS', len(over), 'CELLS', sum(over.values()))
