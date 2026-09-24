#!/usr/bin/env python3
"""hpjoin.py rows.tsv sweepdir — hpcensus on golden+ours of every CMP_EQUAL
row-mode; joins hier_paths by (name, span, occurrence); prints each pair
whose element records differ: corpus mode test ctx golden-elems | ours-elems."""
import collections, concurrent.futures, csv, subprocess, sys
rows = [l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
eq = set()
for c in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{sys.argv[2]}/{c}.csv')):
        if r['status'] == 'CMP_EQUAL':
            eq.add((c, r['mode'], r['name']))
rows = [r for r in rows if (r[0], r[1], r[2]) in eq]
def rec(p):
    out = subprocess.run(['/tmp/r11u124_hpcensus', p], capture_output=True, text=True, timeout=900).stdout
    occ = collections.Counter(); d = {}
    for l in out.splitlines():
        f = l.split('\t')
        if len(f) < 4: continue
        k = (f[1], f[2]); occ[k] += 1
        d[k + (occ[k],)] = f
    return d
def one(r):
    g, o = rec(r[3]), rec(r[4])
    res = []
    for k in g:
        if k in o and g[k][4:] != o[k][4:]:
            res.append('\t'.join(r[:3] + [g[k][3], ' '.join(g[k][4:]), '|', ' '.join(o[k][4:])]))
    return res
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    for res in ex.map(one, rows):
        for l in res: print(l)
