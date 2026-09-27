#!/usr/bin/env python3
"""r11u183: the UVM census keys (uvmcensus9.sh census_rank.csv) that GREW / SHRANK between two runs.
usage: cengrow.py <before census_rank.csv> <after census_rank.csv> [N]"""
import csv, sys
W = {r['key']: r for r in csv.DictReader(open(sys.argv[1]))}; L = {r['key']: r for r in csv.DictReader(open(sys.argv[2]))}
N = int(sys.argv[3]) if len(sys.argv) > 3 else 12; T = ['BuildUVMPkg', 'MiniAmiq', 'Scoreboard', 'SeqDriver', 'SimpleUVM']
rows = []
for k in set(W) | set(L):
    a = int(W[k]['objects']) if k in W else 0; b = int(L[k]['objects']) if k in L else 0
    r = L.get(k) or W.get(k)
    rows.append((b - a, k, a, b, r['map8_id'], ' '.join(f"{t[:4]}:{(L.get(k) or {}).get(t, 0)}" for t in T), r['example'][:170]))
rows.sort()
print('GREW'); [print(' ', r) for r in sorted(rows, reverse=True)[:N] if r[0] > 0]
print('SHRANK'); [print(' ', r[:6]) for r in rows[:N] if r[0] < 0]
print('NET', sum(r[0] for r in rows), 'grown', sum(r[0] for r in rows if r[0] > 0), 'shrunk', sum(r[0] for r in rows if r[0] < 0))
