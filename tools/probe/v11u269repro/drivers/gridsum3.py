#!/usr/bin/env python3
# v11u269 gridsum3.py <grid.txt> [prefix]: per case-view pristine / law / fix verdicts; checks R11U269_OFF (law) and
# FU (fix + R11U269_OFF) give pristine's bytes, FV (fix + R11V269_OFF) the law's, which law switches move the law
# back, whether R11V269_OPKIND_OFF moves the fix; totals for law-vs-pristine and fix-vs-pristine, entering / leaving
# STRICT_EQUAL, uhdm-cmp equality lost (judge-equal -> stage 1) and exit-code changes.
import sys, collections
rows = collections.defaultdict(dict)
pre = sys.argv[2] if len(sys.argv) > 2 else ''
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3 or not f[1].startswith(pre): continue
    d = dict(x.split('=', 1) for x in f[3:] if '=' in x); d['raw'] = ' '.join(f[3:])
    rows[f[1]][f[0]] = d
st = lambda d: d.get('strict', d.get('raw', '?'))
eq = lambda d: st(d).startswith('STRICT_EQUAL')
judge = lambda d: d.get('cmp') == '0'
T = collections.Counter()
for cv in sorted(rows):
    r = rows[cv]; P, L, F = r.get('P', {}), r.get('L', {}), r.get('F', {})
    sw = [c.replace('R11U269_', '').replace('_OFF', '') for c in r if c.startswith('R11U269_') and r[c].get('md5') != L.get('md5')]
    chk = []
    if r.get('OFF', {}).get('md5') != P.get('md5'): chk.append('OFF!=P')
    if r.get('FU', {}).get('md5') != P.get('md5'): chk.append('FU!=P')
    if r.get('FV', {}).get('md5') != L.get('md5'): chk.append('FV!=L')
    if r.get('R11V269_OPKIND_OFF', {}).get('md5') != L.get('md5'): chk.append('OPKIND_OFF!=L')
    fl = []
    for tag, X in (('law', L), ('fix', F)):
        if X.get('md5') != P.get('md5'): T[f'{tag} moving'] += 1
        if eq(X) and not eq(P): T[f'{tag} entering STRICT_EQUAL'] += 1
        if eq(P) and not eq(X): T[f'{tag} LEAVING STRICT_EQUAL'] += 1; fl.append(f'{tag}-LEAVE')
        if judge(P) and not judge(X): T[f'{tag} LOSING uhdm-cmp'] += 1; fl.append(f'{tag}-CMPLOSS')
        if P.get('rc') != X.get('rc'): T[f'{tag} rc changed'] += 1; fl.append(f'{tag}-RC')
    for c in chk: T[c] += 1
    if F.get('md5') != L.get('md5'): T['fix differs from law'] += 1
    T['case-views'] += 1
    print(f'{cv:44s} P={st(P):26s} L={st(L):26s} F={st(F):26s} rc={P.get("rc")}/{L.get("rc")}/{F.get("rc")} lawsw={",".join(sw) or "-"} {" ".join(chk)} {" ".join(fl)}')
print(' '.join(f'{k}={v}' for k, v in sorted(T.items())))
