#!/usr/bin/env python3
# v11u281 gsum.py <grid>: the consolidated grid summary: per case-view P, L and FIX verdicts with rc; the switch
# identities (OFF == P, FIXU == P, FIXV == L); movers, entering / leaving STRICT_EQUAL, rc and uhdm-cmp line changes
# for P->L and P->FIX; per-switch attribution of every P->L mover (law switches) and every L->FIX mover (refinements).
import sys, collections
r = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    x = l.split(); r[x[1]][x[0]] = dict(y.split('=', 1) for y in x[3:] if '=' in y)
eq = lambda k: k.get('cmp') == '0' and 'STRICT_EQUAL' in k.get('strict', '')
SW = ['R11U281_TPPATNEST_OFF', 'R11U281_TPREBINDSPAN_OFF', 'R11U281_TPPORTSPAN_OFF', 'R11U281_IFTPSHARE_OFF', 'R11U281_IFTPUSE_OFF']
SV = ['R11V281_PATNAMED_OFF', 'R11V281_MULTIDECL_OFF']
st = collections.Counter(); att = collections.Counter(); attv = collections.Counter()
for cv in sorted(r):
    d = r[cv]; P, L, F = d['P'], d['L'], d['FIX']
    st['views'] += 1
    st['OFF==P'] += d['OFF']['md5'] == P['md5']; st['FIXU==P'] += d['FIXU']['md5'] == P['md5']; st['FIXV==L'] += d['FIXV']['md5'] == L['md5']
    for tag, X in (('L', L), ('FIX', F)):
        if X['md5'] != P['md5']:
            st[tag + ' moving'] += 1
            st[tag + ' entering'] += (not eq(P)) and eq(X); st[tag + ' leaving'] += eq(P) and not eq(X)
            st[tag + ' rc'] += P['rc'] != X['rc']; st[tag + ' cmplines'] += P['cmplines'] != X['cmplines']
    if L['md5'] != P['md5']:
        back = [s.split('_')[1] for s in SW if d[s]['md5'] == P['md5']]
        moved = [s.split('_')[1] for s in SW if d[s]['md5'] != L['md5']]
        att['one:' + back[0] if len(back) == 1 else 'set:' + '+'.join(moved)] += 1
    if F['md5'] != L['md5']:
        back = [s.split('_')[1] for s in SV if d[s]['md5'] == L['md5']]
        attv['one:' + back[0] if len(back) == 1 else 'set:' + '+'.join(back)] += 1
    print(cv.replace('tp/v11u281repro/cases/', ''), 'P', P['cmp'], P['cmplines'], P['strict'], 'rc' + P['rc'], '| L', L['cmp'], L['cmplines'], L['strict'], 'rc' + L['rc'], '| FIX', F['cmp'], F['cmplines'], F['strict'], 'rc' + F['rc'])
print(dict(st)); print('law attribution', dict(att)); print('refinement attribution', dict(attv))
