#!/usr/bin/env python3
# v11u317 gridsumv.py <gridv.sh output>: per case-view the pristine, law and fix verdicts and exit codes, whether the
# fix moves bytes against pristine and against the law, OFF == pristine, VOFF == law, and the switches that alone
# restore pristine's bytes (R11U317_*) or the law's bytes (R11V317_*) from the fix.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 4: continue
    kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    rows[f[1]][f[0]] = kv
st = collections.Counter(); attr = collections.Counter(); vattr = collections.Counter(); multi = []
def eq(s): return 'STRICT_EQUAL' in (s or '')
for cv in sorted(rows):
    r = rows[cv]; P, L, F = r.get('P', {}), r.get('L', {}), r.get('F', {})
    if not (P and L and F): print('MISSING', cv); continue
    ps, ls, fs = (x.get('strict', x.get('rc')) for x in (P, L, F))
    mvL = P.get('md5') != L.get('md5'); mvF = P.get('md5') != F.get('md5'); fl = L.get('md5') != F.get('md5')
    st['views'] += 1; st['offok'] += r.get('OFF', {}).get('md5') == P.get('md5'); st['voffok'] += r.get('VOFF', {}).get('md5') == L.get('md5')
    st['rcdiff'] += len({P.get('rc'), L.get('rc'), F.get('rc')}) > 1
    if mvL: st['law_moving'] += 1; st['law_enter'] += eq(ls) and not eq(ps); st['law_leave'] += eq(ps) and not eq(ls)
    if mvF: st['fix_moving'] += 1; st['fix_enter'] += eq(fs) and not eq(ps); st['fix_leave'] += eq(ps) and not eq(fs)
    if fl:
        st['fix_vs_law'] += 1
        vs = [t[2:] for t in r if t.startswith('F_R11V317_') and r[t].get('md5') == L.get('md5')]
        for v in vs: vattr[v] += 1
    if mvF:
        sw = [t[2:] for t in r if t.startswith('F_R11U317_') and r[t].get('md5') == P.get('md5')]
        if len(sw) == 1: attr[sw[0]] += 1
        else: multi.append(cv)
    tag = 'MOVE' if (mvL or mvF) else 'SAME'
    print(f"{tag} {cv} P={ps} rc={P.get('rc')} L={ls} rc={L.get('rc')} F={fs} rc={F.get('rc')} cmplines {P.get('cmplines')}/{L.get('cmplines')}/{F.get('cmplines')}{' FIXMOVES' if fl else ''}")
print(dict(st)); print('fix single-switch (R11U317)', dict(attr)); print('fix-vs-law restored by (R11V317)', dict(vattr)); print('pair-or-more', len(multi), ' '.join(multi))
