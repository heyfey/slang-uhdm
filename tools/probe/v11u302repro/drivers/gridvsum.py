#!/usr/bin/env python3
# v11u302 gridvsum.py <gridv.txt>: per case-view the pristine / law / fix verdicts; totals for law vs pristine and fix
# vs pristine (movers, entering / leaving STRICT_EQUAL, rc and uhdm-cmp changes), the fix-vs-law movers with the
# refinement switch that restores the law's bytes, and the byte checks fix+R11U302_OFF == pristine, fix+R11V302_OFF == law.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.rstrip('\n').split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3]
f = lambda s, k: (re.search(k + r'=(\S+)', s) or [None, ''])[1]
vd = lambda s: ' '.join(x for x in s.split() if not x.startswith('md5='))
tot = collections.Counter()
for (c, v), r in sorted(rows.items()):
    p, L, F = r['pristine'], r['law'], r['fix']
    tot['views'] += 1
    for tag, x in (('law', L), ('fix', F)):
        if f(x, 'rc') != f(p, 'rc'): tot[tag + '_rc_changes'] += 1; print('RC', tag, c, v, f(p, 'rc'), '->', f(x, 'rc'))
        if f(x, 'cmp') != f(p, 'cmp'): tot[tag + '_cmp_changes'] += 1; print('CMP', tag, c, v, f(p, 'cmp'), '->', f(x, 'cmp'))
        if f(x, 'md5') != f(p, 'md5'):
            tot[tag + '_movers'] += 1
            tot[tag + '_entering'] += ('STRICT_EQUAL' in x and 'STRICT_EQUAL' not in p)
            tot[tag + '_leaving'] += ('STRICT_EQUAL' in p and 'STRICT_EQUAL' not in x)
    tot['U_OFF_eq_pristine'] += f(r['fix+R11U302_OFF'], 'md5') == f(p, 'md5')
    tot['V_OFF_eq_law'] += f(r['fix+R11V302_OFF'], 'md5') == f(L, 'md5')
    if f(F, 'md5') != f(L, 'md5'):
        tot['fix_vs_law'] += 1
        rest = [sw for sw in ('LITVAL', 'SOLEWRITER') if f(r['fix+R11V302_%s_OFF' % sw], 'md5') == f(L, 'md5')]
        tot['fix_vs_law_pristine_bytes'] += f(F, 'md5') == f(p, 'md5')
        print('FIXvsLAW', c, v, '| P:', vd(p), '| L:', vd(L), '| F:', vd(F), '| restored by', ','.join(rest) or '-', '| fix==pristine' if f(F, 'md5') == f(p, 'md5') else '')
print(' '.join(f'{k}={tot[k]}' for k in sorted(tot)))
