#!/usr/bin/env python3
# v11u268 gridsum3.py <grid3 output>: per case-view P / L / F verdicts; checks FV == L and FU == P bytes, the
# uhdm-cmp line count unchanged, rc; counts movers (F vs P), entering / leaving STRICT_EQUAL, and F != L.
import sys, collections
# a SURELOG_FAIL line (no golden) carries no strict / md5 field: compared as the token 'SURELOG_FAIL'
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split(); d = dict(x.split('=', 1) for x in f[3:] if '=' in x); d.setdefault('strict', f[3] if len(f) > 3 and '=' not in f[3] else '-'); d.setdefault('md5', '-'); rows[f[1]][f[0]] = d
bad = []; mv = ent = lv = fl = 0
for c, r in sorted(rows.items()):
    P, L, F, FV, FU = (r[k] for k in ['P', 'L', 'F', 'FV', 'FU'])
    if FV.get('md5') != L.get('md5'): bad.append((c, 'FV!=L'))
    if FU.get('md5') != P.get('md5'): bad.append((c, 'FU!=P'))
    if P.get('cmplines') != F.get('cmplines') or P.get('rc') != F.get('rc'): bad.append((c, 'cmp/rc'))
    pe = P['strict'].startswith('STRICT_EQUAL'); fe = F['strict'].startswith('STRICT_EQUAL')
    m = F['md5'] != P['md5']; mv += m; ent += fe and not pe; lv += pe and not fe; fl += F['md5'] != L['md5']
    print(c, P['strict'], '|', L['strict'], '|', F['strict'], 'move' if m else '-', 'F!=L' if F['md5'] != L['md5'] else '')
print('case-views', len(rows), 'moving', mv, 'entering', ent, 'leaving', lv, 'fix-vs-law', fl, 'bad', bad)
