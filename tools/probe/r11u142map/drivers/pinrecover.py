#!/usr/bin/env python3
"""r11u138: recover pins from a pinmulti run whose parent was OOM-killed (the gdb
script saves its hits per hit): want.json (type -> rank -> cluster ids) + hits.json
-> pins.txt-shaped entries. Args: <pmtmp dir> <row label> <out>"""
import json, sys, re
D, ROW, OUT = sys.argv[1:4]
w = json.load(open(f'{D}/want.json')); h = json.load(open(f'{D}/hits.json'))
got = {(t, str(c)): fr for t, c, fr in h}
def short(name):
    if 'operator()' in name and 'lambda' in name: return 'operator()'
    n = re.sub(r'<.*>', '', name); n = re.sub(r'\(.*$', '', n); n = n.split('::')[-1] or name
    return 'operator()' if n == 'operator' else n
n = m = 0
with open(OUT, 'w') as o:
    for t, rs in w.items():
        for r, ks in rs.items():
            fr = got.get((t, r))
            if not fr: m += len(ks); continue
            for k in ks:
                n += 1; o.write(f'== {k} {ROW} object (recovered) {t} rank {r}\n  rank {r}:\n')
                for i, name, fn, ln in fr: o.write(f'    #{i} {short(name)} at {fn}:{ln}\n')
print('recovered', n, 'missing', m)
