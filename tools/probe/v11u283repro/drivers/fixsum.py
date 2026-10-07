#!/usr/bin/env python3
# v11u283 fixsum.py <fixgrid.txt>: per case-view P / L / F / FV / FU; checks FV == L and FU == P bytes;
# lists every case-view where F differs from L, and the P -> F movers (entering / leaving STRICT_EQUAL, rc changes).
import sys, re, collections
d = collections.defaultdict(dict)
for ln in open(sys.argv[1]):
    f = ln.split()
    if len(f) < 3: continue
    cfg, rel = f[0], f[1]
    kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    st = kv.get('strict', f[3] if len(f) > 3 else '?')
    d[rel][cfg] = (kv.get('md5', f[2] if 'FAIL' in f[2] else '?'), st, kv.get('rc'), kv.get('cmplines'))
n = len(d); fvl = sum(1 for r in d.values() if r['FV'][0] == r['L'][0]); fup = sum(1 for r in d.values() if r['FU'][0] == r['P'][0])
mv = ent = lv = rcc = 0
for rel in sorted(d):
    r = d[rel]
    if r['F'][0] != r['L'][0]:
        print('F!=L %-50s P=%s L=%s F=%s' % (rel, r['P'][1], r['L'][1], r['F'][1]))
    if r['F'][0] != r['P'][0]:
        mv += 1
        pe = r['P'][1].startswith('STRICT_EQUAL'); fe = r['F'][1].startswith('STRICT_EQUAL')
        ent += (fe and not pe); lv += (pe and not fe)
        if pe and not fe: print('LEAVING', rel, r['P'][1], r['F'][1])
    if r['F'][2] != r['P'][2]: rcc += 1; print('RC', rel, r['P'][2], r['F'][2])
print('case-views=%d FV==L %d/%d FU==P %d/%d P->F moving=%d entering=%d leaving=%d rc_changed=%d' % (n, fvl, n, fup, n, mv, ent, lv, rcc))
