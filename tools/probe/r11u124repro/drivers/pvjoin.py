#!/usr/bin/env python3
"""pvjoin.py rows.tsv sweep_dir — runs pvcensus on golden and ours of every
CMP_EQUAL row-mode, joins the param_assign records by (view, fullname,
occurrence) and prints each (golden param value, ours param value, golden
Rhs kind/value, ours Rhs kind/value) whose param value differs."""
import collections, concurrent.futures, csv, subprocess, sys
rows = [l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
eq = set()
for c in ('surelog', 'uhdm2rtlil'):
    try:
        for r in csv.DictReader(open(f'{sys.argv[2]}/{c}.csv')):
            if r['status'] == 'CMP_EQUAL':
                eq.add((c, r['mode'], r['name']))
    except FileNotFoundError:
        pass
rows = [r for r in rows if (r[0], r[1], r[2]) in eq]
T = "/tmp/r11u124_pvcensus"
import os
ALL = os.environ.get("PV_ALL") == "1"
def one(r):
    def rec(p):
        out = subprocess.run([T, p], capture_output=True, text=True, timeout=600).stdout
        occ = collections.Counter(); d = {}
        for l in out.splitlines():
            f = l.split('\t')
            if len(f) < 10: continue
            k = (f[0], f[1]); occ[k] += 1
            d[k + (occ[k],)] = f
        return d
    g, o = rec(r[3]), rec(r[4])
    res = []
    for k in g:
        if k in o and (ALL or g[k][2] != o[k][2]):
            res.append('\t'.join(r[:3] + [k[0], k[1], 'G=' + g[k][2], 'O=' + o[k][2], 'Grhs=' + g[k][3] + ':' + g[k][4], 'Orhs=' + o[k][3] + ':' + o[k][4], o[k][6], o[k][7], o[k][8], o[k][9]]))
    return res
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    for res in ex.map(one, rows):
        for l in res:
            print(l)
