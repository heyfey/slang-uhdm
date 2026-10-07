#!/usr/bin/env python3
# v11u274 vgridsum.py <vgrid.txt>: per case-view, pristine / law / fix: movers of fix against pristine (entering,
# leaving STRICT_EQUAL, exit-code and uhdm-cmp changes), fix+R11V274_OFF == law, fix+R11U274_OFF == pristine,
# fix against law movers each attributed to the R11V274 switch that restores the law's bytes.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3].strip()
f = lambda s, k: (re.search(k + r'=(\S+)', s) or [None, ''])[1]
eq = lambda s: 'STRICT_EQUAL' in s
st = lambda s: re.sub(r' md5=\S+', '', s)
n = mv = ent = lea = rcc = cmpc = voff = uoff = 0; fl = collections.Counter(); out = []
for (c, v), r in sorted(rows.items()):
    p, L, X = r['pristine'], r['law'], r['fix']; n += 1
    voff += f(r.get('fix+R11V274_OFF', ''), 'md5') == f(L, 'md5')
    uoff += f(r.get('fix+R11U274_OFF', ''), 'md5') == f(p, 'md5')
    rcc += f(p, 'rc') != f(X, 'rc'); cmpc += f(p, 'cmp') != f(X, 'cmp')
    if f(p, 'md5') != f(X, 'md5'):
        mv += 1; ent += eq(X) and not eq(p); lea += eq(p) and not eq(X)
    if f(L, 'md5') != f(X, 'md5'):
        sws = [k[4:] for k in r if k.startswith('fix+R11V274_') and k != 'fix+R11V274_OFF' and f(r[k], 'md5') == f(L, 'md5')]
        for s in sws: fl[s] += 1
        out.append(f'FIXMOVER {c} {v}: pristine[{st(p)}] law[{st(L)}] fix[{st(X)}] restored-by {sws}')
print('\n'.join(out))
print(f'case-views {n}; fix vs pristine: moving {mv}, entering STRICT_EQUAL {ent}, leaving {lea}, exit-code changes {rcc}, '
      f'uhdm-cmp line changes {cmpc}; fix+R11V274_OFF == law {voff}/{n}; fix+R11U274_OFF == pristine {uoff}/{n}; '
      f'fix vs law movers {len(out)} restored by {dict(fl)}')
