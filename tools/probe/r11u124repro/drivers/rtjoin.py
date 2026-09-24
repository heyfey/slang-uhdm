#!/usr/bin/env python3
"""rtjoin.py rows.tsv sweepdir — rtcensus on golden+ours of every CMP_EQUAL
row-mode; joins ref_typespecs by (holder, holder span, grand-holder, actual
kind, occurrence); prints each whose full name differs."""
import collections, concurrent.futures, csv, os, subprocess, sys
FILT = os.environ.get('RT_OPALL') == '1'
rows = [l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
eq = set()
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{sys.argv[2]}/{c}.csv')):
        if r['status'] == 'CMP_EQUAL':
            eq.add((c, r['mode'], r['name']))
rows = [r for r in rows if (r[0], r[1], r[2]) in eq]
def rec(p):
    out = subprocess.run(['/tmp/r11u124_rtcensus', p], capture_output=True, text=True, timeout=900).stdout
    occ = collections.Counter(); d = {}
    for l in out.splitlines():
        f = l.split('\t')
        if len(f) < 7: continue
        k = (f[0], f[1], f[2], f[5]); occ[k] += 1
        d[k + (occ[k],)] = f
    return d
def one(r):
    g, o = rec(r[3]), rec(r[4])
    res = []
    for k in g:
        if k in o and (g[k][4] != o[k][4] or (FILT and g[k][0].startswith('operation'))):
            res.append('\t'.join(r[:3] + list(k[:4]) + ['G:' + g[k][3], 'O:' + o[k][3], 'Gfn=' + g[k][4], 'Ofn=' + o[k][4], g[k][6]]))
    return res
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    for res in ex.map(one, rows):
        for l in res: print(l)
