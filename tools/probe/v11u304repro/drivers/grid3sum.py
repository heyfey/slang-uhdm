#!/usr/bin/env python3
# v11u304 grid3sum.py <grid3.txt>: per case-view, pristine / law / fix lines; prints fix-vs-law differences,
# law and fix movers against pristine, the switch byte checks (fix+R11U304_OFF == pristine, fix+R11V304_OFF == law)
# and, for each fix-vs-law case-view, which single R11V304 switch restores the law's bytes.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.rstrip('\n').split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3]
f = lambda s, k: (re.search(k + r'=(\S+)', s) or [None, ''])[1]
V = lambda s: ' '.join(x for x in s.split() if not x.startswith(('md5=',)))
n = 0; st = collections.Counter(); att = collections.Counter()
for (c, v), r in sorted(rows.items()):
    n += 1; p, L, F = r['pristine'], r['law'], r['fix']
    st['uoff_eq_pristine'] += f(r['fix+R11U304_OFF'], 'md5') == f(p, 'md5')
    st['voff_eq_law'] += f(r['fix+R11V304_OFF'], 'md5') == f(L, 'md5')
    for lab, x in (('law', L), ('fix', F)):
        if f(x, 'rc') != f(p, 'rc'): st[lab + '_rc_change'] += 1; print('RC', lab, c, v, f(p, 'rc'), '->', f(x, 'rc'))
        if f(x, 'md5') != f(p, 'md5'):
            st[lab + '_movers'] += 1
            pe, xe = 'STRICT_EQUAL' in p, 'STRICT_EQUAL' in x
            st[lab + '_enter'] += xe and not pe; st[lab + '_leave'] += pe and not xe
            if pe and not xe: print('LEAVE', lab, c, v, V(p), '->', V(x))
    if f(F, 'md5') != f(L, 'md5'):
        st['fix_vs_law'] += 1
        sw = [k[4:] for k in r if k.startswith('fix+R11V304_') and k != 'fix+R11V304_OFF' and f(r[k], 'md5') == f(L, 'md5')]
        att[' '.join(sw) or 'none'] += 1
        print(f'FIXVSLAW {c} {v}: law {V(L)} | fix {V(F)} | pristine {V(p)} | restored-by {sw}')
print(f'case-views={n}', ' '.join(f'{k}={v}' for k, v in sorted(st.items())), 'attrib', dict(att))
