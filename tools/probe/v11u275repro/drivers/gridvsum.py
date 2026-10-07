#!/usr/bin/env python3
# v11u275 gridvsum.py <gridv.txt>: per case-view the verdicts on P, L, F; FV == L bytes, FU == P bytes, the F-vs-L
# movers attributed (FK == L: the KEEPACTUAL switch), the F-vs-P and L-vs-P entering / leaving / uhdm-cmp / exit-code
# changes; then the totals.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 4: continue
    kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    st = kv.get('strict', f[3])
    rows[f[1]][f[0]] = (st, kv.get('md5', '-'), kv.get('rc', '?'), kv.get('cmplines', '-'))
tot = collections.Counter()
eq = lambda s: s.startswith('STRICT_EQUAL')
for rel in sorted(rows):
    r = rows[rel]
    if not all(k in r for k in ('P', 'L', 'F', 'FV', 'FU', 'FK')):
        print(rel, 'INCOMPLETE'); tot['incomplete'] += 1; continue
    P, L, F = r['P'], r['L'], r['F']
    tot['caseviews'] += 1
    tot['FV_eq_L'] += r['FV'][1] == L[1]; tot['FU_eq_P'] += r['FU'][1] == P[1]
    for tag, X in (('L', L), ('F', F)):
        mv = X[1] != P[1]
        tot[f'{tag}_moved'] += mv
        tot[f'{tag}_enter'] += mv and not eq(P[0]) and eq(X[0])
        tot[f'{tag}_leave'] += mv and eq(P[0]) and not eq(X[0])
        tot[f'{tag}_cmpchange'] += X[3] != P[3]
        tot[f'{tag}_rcchange'] += X[2] != P[2]
    fl = F[1] != L[1]
    tot['F_vs_L_moved'] += fl
    tot['F_vs_L_by_KEEPACTUAL'] += fl and r['FK'][1] == L[1]
    flag = []
    if fl: flag.append('FvsL' + ('(KEEPACTUAL)' if r['FK'][1] == L[1] else '(UNATTRIBUTED)'))
    if F[1] != P[1] and eq(P[0]) and not eq(F[0]): flag.append('LEAVE')
    if F[3] != P[3]: flag.append('CMPCHANGE')
    if F[2] != P[2]: flag.append('RCCHANGE')
    print(f"{rel} P={P[0]} L={L[0]} F={F[0]} rc={P[2]}/{L[2]}/{F[2]} cmplines={P[3]}/{L[3]}/{F[3]} FV=L:{int(r['FV'][1]==L[1])} FU=P:{int(r['FU'][1]==P[1])} {' '.join(flag)}")
print('TOTAL', ' '.join(f'{k}={v}' for k, v in sorted(tot.items())))
