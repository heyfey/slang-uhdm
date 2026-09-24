#!/usr/bin/env python3
"""r11u132: the numbers final.py does not print. Full-name facet classes under
mode 4 (OUT = outside any copy; TAIL = inside a copy, the tails differ; STABLE =
inside a copy, tails equal, but golden does not give ours's object several
names including ours's), rows near the flip after the pairs (open clusters per
row), family-extended pair yields (an upper bound), probe by law.
Args: <work dir> <out dir>"""
import os, sys, json, collections, csv
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
W, OUT = sys.argv[1:3]
ids = json.load(open(f'{W}/ids.json')); cid, cov, famOf = ids['cid'], ids['cov'], ids['famOf']
RC = [json.loads(l) for l in open(f'{W}/corpus.jsonl')]; RP = [json.loads(l) for l in open(f'{W}/probe.jsonl')]
P = print
fc = collections.Counter(); fcr = collections.defaultdict(set); fco = collections.Counter()
rows = {}; prow = {}
for r in RC:
    k = (r['corpus'], r['mode'], r['test']); rows[k] = set()
    for x in r['rows']:
        c = rekey(x); rows[k].add(c)
        if x['facet'] == 'fullname':
            fc[x['fnclass']] += 1; fcr[x['fnclass']].add(k)
for r in RP:
    prow[r['test']] = {rekey(x) for x in r['rows']}
P('== full-name facets by class (objects / row-modes)')
for c in ('OUT', 'TAIL', 'STABLE'): P(c, fc[c], len(fcr[c]))
iscov = lambda c: cov[c].startswith('COVERED')
covAB = {c for c in cid if iscov(c)}
P('== rows after the pairs: open clusters per row (histogram: n_open -> row-modes)')
h = collections.Counter(sum(1 for c in s if not iscov(c)) for s in rows.values())
P(sorted(h.items())[:15], '... max', max(h))
one = collections.Counter()
for k, s in rows.items():
    o = [c for c in s if not iscov(c)]
    if len(o) == 1: one[o[0]] += 1
P('== clusters that are the ONLY open cluster of a row (row-modes they would clear on top of the pairs), top 30')
for c, n in one.most_common(30): P(cid[c], n, cov[c], c)
fa = {famOf[c] for c in cid if 'r11u131' in cov[c]}; fb = {famOf[c] for c in cid if 'r11u130' in cov[c]}
P('== family-extended pairs (UPPER bound: every cluster of a family the pair touches):')
P('  A families', sorted(fa)); P('  B families', sorted(fb))
for tag, fs in (('A', fa), ('B', fb), ('A+B', fa | fb)):
    S = {c for c in cid if famOf[c] in fs} | {c for c in cid if (tag in ('A', 'A+B') and 'r11u131' in cov[c]) or (tag in ('B', 'A+B') and 'r11u130' in cov[c])}
    P(f'  {tag}: clusters {len(S)} rows cleared {sum(1 for s in rows.values() if s <= S)} probe {sum(1 for s in prow.values() if s <= S)}')
