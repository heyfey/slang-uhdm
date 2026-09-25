#!/usr/bin/env python3
"""r11u156: audit of this map's own pair-A prediction against pass 147 (b6af876c), which landed while the map ran.
Rows: this map's pristine fail list (out/fail_list.csv after report7.py) against pass 147's committed baselines; clusters:
this map's pristine cluster rows against the re-keyed pass-147 integration sweep (WS2/corpus.jsonl).
Args: <map out dir> <WS2> <golden dir at b6af876c> <W (ids.json)>"""
import csv, sys, json, collections, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import rekey
OUT, WS2, G, W = sys.argv[1:5]
cid = json.load(open(f'{W}/ids.json'))['cid']
F = {(r['corpus'], r['mode'], r['test']): r for r in csv.DictReader(open(f'{OUT}/fail_list.csv')) if r['first_cluster'] != 'FENCED'}
CI = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
now = set()
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{G}/golden_{c}.csv')):
        if r['status'] == 'STRICT_NOTEQUAL': now.add((c, r['mode'], r['name']))
moved = sorted(k for k in F if k not in now)
CL = collections.defaultdict(set)
for r in csv.DictReader(open(f'{OUT}/clusters.csv')): CL[(r['corpus'], r['mode'], r['test'])].add(r['cluster_id'])
tagA = lambda k: F[k]['clears_after_both_pairs']
isA = lambda c: 'r11u147' in CI[c]['coverage'].split('(')[0] and CI[c]['coverage'].startswith('COVERED')
predA = {k for k in F if F[k]['clears_after_both_pairs'] != 'no' and all(isA(c) or 'r11u152' not in CI[c]['coverage'] for c in CL[k] if CI[c]['coverage'].startswith('COVERED'))}
print(f'# pass 147 moved {len(moved)} of this map\'s {len(F)} dispatched row-modes (the fenced pair moved too, not dispatched here)')
for k in moved:
    cl = sorted(CL[k])
    print(f"  {k[0]}/{k[1]}/{k[2]}  map7 said: {tagA(k)}  first={F[k]['first_cluster']}  clusters: " + ' '.join(f"{c}[{'A' if isA(c) else ('B' if CI[c]['coverage'].startswith('COVERED') else 'open')}]" for c in cl))
# rows map 7 predicted cleared by pair A alone (every covered cluster pair A's, law or named) that did not move
pa = sorted(k for k in F if F[k]['clears_after_both_pairs'] != 'no' and all(isA(c) for c in CL[k]))
print(f'\n# rows this map predicted cleared by pair A alone (law measured + named optimistic): {len(pa)}; moved {sum(1 for k in pa if k in moved)}')
for k in pa: print(f"  {'MOVED' if k in moved else 'NOT MOVED'} {k[0]}/{k[1]}/{k[2]}  {F[k]['clears_after_both_pairs']}  clusters {' '.join(sorted(CL[k]))}")
# cluster level
rc0 = collections.Counter(); rc1 = collections.Counter()
for k, s in CL.items():
    for c in s: rc0[c] += 1
for l in open(f'{WS2}/corpus.jsonl'):
    r = json.loads(l); s = {cid.get(rekey(x), 'NEW') for x in r['rows']}
    for c in s: rc1[c] += 1
A = sorted(c for c in CI if isA(c) and rc0[c])
print(f'\n# pair-A covered clusters (law + named + routed) with a row at 89d599ef: {len(A)}')
for tag, L in (('gone', [c for c in A if rc1[c] == 0]), ('fell', [c for c in A if 0 < rc1[c] < rc0[c]]), ('unchanged', [c for c in A if rc1[c] >= rc0[c]])):
    print(f'  {tag} {len(L)}: ' + ' '.join(f'{c} {rc0[c]}->{rc1[c]}' for c in L))
other = sorted((c for c in rc0 if not isA(c) and rc1[c] < rc0[c]), key=lambda c: rc1[c] - rc0[c])
print(f'\n# clusters NOT covered by pair A that pass 147 cleared or reduced: {len(other)}')
print('  ' + ' '.join(f"{c} {rc0[c]}->{rc1[c]} ({CI[c]['coverage'][:24]}; {CI[c]['ground'] if 'ground' in CI[c] else ''})" for c in other))
