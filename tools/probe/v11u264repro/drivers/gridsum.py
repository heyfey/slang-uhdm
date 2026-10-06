#!/usr/bin/env python3
# (v11u264: from r11u264repro/drivers/gridsum.py) gridsum.py <grid.txt>: per case-view the P, L and F verdicts,
# whether R11U264_OFF gives P's bytes and R11V264_OFF gives L's, which switches move F back; then the totals.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 4: continue
    cfg, cv = f[0], f[1]
    d = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    d['raw'] = ' '.join(f[3:])
    rows[cv][cfg] = d
tot = collections.Counter()
def eq(v): return v.startswith('STRICT_EQUAL')
for cv in sorted(rows):
    r = rows[cv]; P, L, F, O, V = (r.get(k, {}) for k in ('P', 'L', 'F', 'OFF', 'VOFF'))
    sw = [c.replace('_OFF', '') for c in r if c.startswith('R11') and r[c].get('md5') != F.get('md5')]
    off = 'off=P' if O.get('md5') == P.get('md5') else 'off=DIFFERS'
    voff = 'voff=L' if V.get('md5') == L.get('md5') else 'voff=DIFFERS'
    pv, lv, fv = (x.get('strict', x.get('raw', '?')) for x in (P, L, F))
    rc = 'rc=%s/%s/%s' % (P.get('rc'), L.get('rc'), F.get('rc'))
    print(f'{cv:42s} P={pv:28s} L={lv:28s} F={fv:28s} {off} {voff} {rc} cmpl={P.get("cmplines")}/{L.get("cmplines")}/{F.get("cmplines")} sw={",".join(sw) or "-"}')
    tot['case-views'] += 1; tot[off] += 1; tot[voff] += 1
    for tag, X in (('L', L), ('F', F)):
        if X.get('md5') != P.get('md5'): tot[f'{tag} moving'] += 1
        xv = X.get('strict', '')
        if eq(xv) and not eq(pv): tot[f'{tag} entering STRICT_EQUAL'] += 1
        if eq(pv) and not eq(xv): tot[f'{tag} LEAVING STRICT_EQUAL'] += 1
        if pv.startswith('STRICT') and xv.startswith('NOT_EQUAL'): tot[f'{tag} LEAVING judge-equal'] += 1
        if P.get('rc') != X.get('rc'): tot[f'{tag} rc changed'] += 1
    if F.get('md5') != L.get('md5'): tot['F differs from L'] += 1
print(' '.join(f'{k}={v}' for k, v in sorted(tot.items())))
