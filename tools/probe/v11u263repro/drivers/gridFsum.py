#!/usr/bin/env python3
# (v11u263) gridFsum.py <gridF.txt>: per case-view P / L / F verdicts and md5s; checks VOFF == L and UOFF == P bytes;
# names the switch(es) that move F's bytes; counts movers, entries into STRICT_EQUAL, departures, rc != 0.
import sys, collections
rows = collections.defaultdict(dict)
bad_rc = 0
for l in open(sys.argv[1]):
    f = l.split()
    cfg, cv = f[0], f[1]
    kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    if kv.get('rc') != '0': bad_rc += 1
    rows[cv][cfg] = (kv.get('strict', f[3] if len(f) > 3 else '?'), kv.get('md5', '?'), kv.get('cmplines', '?'))
n = mv = ent = lv = voff_bad = uoff_bad = 0
for cv, r in rows.items():
    n += 1
    P, L, F = r['P'], r['L'], r['F']
    if r['VOFF'][1] != L[1]: voff_bad += 1
    if r['UOFF'][1] != P[1]: uoff_bad += 1
    sws = [k for k in r if k.startswith('R11') and r[k][1] != F[1]]
    moved = F[1] != P[1]
    if moved: mv += 1
    eq = lambda v: v[0].startswith('STRICT_EQUAL')
    if eq(F) and not eq(P): ent += 1
    if eq(P) and not eq(F): lv += 1
    tag = 'MOVE' if moved else 'same'
    print(f"{cv:45s} P={P[0]}({P[2]}) L={L[0]}({L[2]}) F={F[0]}({F[2]}) {tag} sw={','.join(s.replace('_OFF','') for s in sws) or '-'}{' L!=F' if L[1]!=F[1] else ''}")
print(f"case-views={n} rc!=0 lines={bad_rc} F-moving={mv} entering_STRICT_EQUAL={ent} leaving={lv} VOFF!=L={voff_bad} UOFF!=P={uoff_bad}")
