#!/usr/bin/env python3
"""r11u191: each named row's first N differing records (walk order, ia) with map 10's cluster id (common.rekey +
r11u189map/cluster_index.csv) and r11u175's UVM family (uvmfamilies.fam), from an analyze.py jsonl.
usage: first10.py <analyze.jsonl> <N> <test>...   Refuses the four fenced names (common.fenced(), fail closed)."""
import sys, os, json, csv, re
H = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, H)
from common import fenced, rekey
F = fenced()
ana, N, tests = sys.argv[1], int(sys.argv[2]), sys.argv[3:]
for t in tests:
    assert t not in F, 'fenced row refused'
K = {r['key']: r for r in csv.DictReader(open(os.path.join(H, '..', '..', 'r11u189map', 'cluster_index.csv')))}
sys.argv = ['x', os.devnull, os.devnull]
src = open(os.path.join(H, 'uvmfamilies.py')).read()
fam_src = src[src.index('def fam('):src.index('\n', src.index('return \'F9') if 'F9' in src else len(src)-1)]
ns = {'re': re}
try:
    exec(src.split('rows = list')[0] + src[src.index('def fam('):].split('\nfam_rows')[0].split('\nper =')[0], ns)
    fam = ns['fam']
except Exception as e:
    fam = lambda r: '?'
for l in open(ana):
    r = json.loads(l)
    if r['test'] not in tests: continue
    fs = sorted([f for f in r['rows'] if f['ia'] >= 0], key=lambda f: (f['ia'], f['facet']))
    print(f"== {r['test']} {r['mode']}: {len(r['rows'])} facet rows")
    seen = 0; last = None
    for f in fs:
        if f['ia'] != last: seen += 1; last = f['ia']
        if seen > N: break
        k = rekey(f); m = K.get(k, {})
        try: fm = fam({'key': k, 'map8_coverage': m.get('coverage', ''), 'site': m.get('site', '')})
        except Exception: fm = '?'
        print(f"  #{f['ia']}/{f['ib']} {m.get('cluster_id','NEW')} [{m.get('ground','')}] {f['facet']} {f['type']} '{f['name']}' g={f['golden'][:70]!r} o={f['ours'][:70]!r} < {f['chain'][:90]}  {{{fm.split(' ')[0]}}}")
