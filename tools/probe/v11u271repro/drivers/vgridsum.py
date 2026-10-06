#!/usr/bin/env python3
# v11u271 vgridsum.py <vgrid.txt>: per case-view P/L/F/FV/FOFF and F with each switch off. Checks FOFF == P bytes
# (R11U271_OFF gives pristine) and FV == L bytes (R11V271_OFF gives the law); counts movers of F against P and of F
# against L, STRICT_EQUAL entering / leaving, uhdm-cmp losses, rc changes; attributes each F-vs-P mover to the
# switches that return P's bytes and each F-vs-L mover to the verifier's switch.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 4: continue
    rows[p[1]][p[0]] = dict(x.split('=', 1) for x in p[3:] if '=' in x)
t = collections.Counter()
def eq(s): return s.startswith('STRICT_EQUAL')
for cv in sorted(rows):
    r = rows[cv]; P, L, F, FV, FO = (r.get(k, {}) for k in ('P', 'L', 'F', 'FV', 'FOFF'))
    t['caseviews'] += 1
    if FO.get('md5') != P.get('md5'): t['FOFF_not_P'] += 1; print('FOFFDIFF', cv)
    if FV.get('md5') != L.get('md5'): t['FV_not_L'] += 1; print('FVDIFF', cv)
    if len({P.get('rc'), L.get('rc'), F.get('rc')}) > 1: t['rc_changed'] += 1; print('RC', cv, P.get('rc'), L.get('rc'), F.get('rc'))
    ps, ls, fs = P.get('strict', ''), L.get('strict', ''), F.get('strict', '')
    if F.get('md5') != P.get('md5'):
        t['F_vs_P_moving'] += 1
        att = [k[2:] for k in r if k.startswith('F_') and r[k].get('md5') == P.get('md5')]
        t['attrib_%d' % len(att)] += 1
        if eq(fs) and not eq(ps): t['F_vs_P_entering'] += 1
        if eq(ps) and not eq(fs): t['F_vs_P_leaving'] += 1; print('LEAVE', cv)
        if P.get('cmplines') == '0' and F.get('cmplines') != '0': t['F_vs_P_losing_cmp'] += 1; print('LOSECMP', cv)
        print('MOVER_P', cv, ps, '->', fs, 'by', ','.join(att) or '-')
    if F.get('md5') != L.get('md5'):
        t['F_vs_L_moving'] += 1
        if L.get('cmplines') != '0' and F.get('cmplines') == '0': t['F_vs_L_regaining_cmp'] += 1
        if eq(ls) and not eq(fs): t['F_vs_L_leaving'] += 1; print('LEAVE_L', cv)
        byv = [k[2:] for k in ('F_R11V271_LAWLHSTS_OFF', 'F_R11V271_MODCLASS_OFF') if r.get(k, {}).get('md5') == L.get('md5')]
        for k in byv: t['F_vs_L_by_' + k] += 1
        print('MOVER_L', cv, ls, '->', fs, 'by', ','.join(byv) or 'UNATTRIBUTED(both)')
print(' '.join('%s=%d' % kv for kv in sorted(t.items())))
