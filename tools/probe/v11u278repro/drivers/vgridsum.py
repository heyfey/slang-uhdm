#!/usr/bin/env python3
# v11u278 vgridsum.py <vgrid.txt>: per case-view (vgrid.sh lines): pristine against the fix and against the law
# (database md5), entering / leaving STRICT_EQUAL, exit-code and uhdm-cmp line changes, the fix + R11V278_OFF equal
# to the law, the fix + R11U278_OFF equal to pristine, and the switch(es) that give back pristine's bytes (the four
# law switches) or the law's bytes (R11V278_OVRTPREF_OFF) for each mover.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3].strip()
def f(s, k):
    m = re.search(k + r'=(\S+)', s); return m.group(1) if m else ''
eq = lambda s: 'STRICT_EQUAL' in s
strip = lambda s: re.sub(r' md5=\S+', '', s)
c = collections.Counter(); attr = collections.Counter(); multi = []; out = []
for (cs, v), r in sorted(rows.items()):
    p, L, X = r.get('pristine', ''), r.get('law', ''), r.get('fix', '')
    c['views'] += 1
    c['v_off_eq_law'] += f(r.get('fix+R11V278_OFF', ''), 'md5') == f(L, 'md5')
    c['u_off_eq_pris'] += f(r.get('fix+R11U278_OFF', ''), 'md5') == f(p, 'md5')
    for a, b, tag in ((p, L, 'law'), (p, X, 'fix')):
        if f(a, 'rc') != f(b, 'rc'): c[f'{tag}_rc_change'] += 1
        if f(a, 'cmp') != f(b, 'cmp'): c[f'{tag}_cmp_change'] += 1
        if f(a, 'md5') != f(b, 'md5'):
            c[f'{tag}_moving'] += 1
            if eq(b) and not eq(a): c[f'{tag}_entering'] += 1
            if eq(a) and not eq(b): c[f'{tag}_leaving'] += 1
    if f(L, 'md5') != f(X, 'md5'):
        c['fix_vs_law_moving'] += 1
        out.append(f'FIXMOVER {cs} {v}: law {strip(L)} -> fix {strip(X)} [OVRTPREF_OFF gives law: '
                   f'{f(r.get("fix+R11V278_OVRTPREF_OFF", ""), "md5") == f(L, "md5")}]')
    if f(p, 'md5') != f(X, 'md5'):
        sws = [k[4:] for k in r if k.startswith('fix+R11U278_') and k != 'fix+R11U278_OFF' and f(r[k], 'md5') == f(p, 'md5')]
        for s in sws: attr[s] += 1
        if len(sws) != 1: multi.append(f'{cs} {v} {sws}')
        out.append(f'MOVER {cs} {v}: {strip(p)} -> {strip(X)} [{",".join(sws)}]')
print('\n'.join(out))
print(' '.join(f'{k}={c[k]}' for k in sorted(c)))
print('restored to pristine by exactly one law switch:', dict(attr), '; not exactly one:', multi)
