#!/usr/bin/env python3
# v11u276 gridsum3.py <grid3.txt> [A B]: per case-view, variant A against variant B (default pristine fix): moved
# (database md5), entering / leaving STRICT_EQUAL, exit-code and uhdm-cmp line changes, and the switch(es) of the fix
# binary that give A's bytes back for each mover; also fix+R11V276_OFF == law and fix+R11U276_OFF == pristine counts.
import sys, re, collections
A, B = (sys.argv[2], sys.argv[3]) if len(sys.argv) > 3 else ('pristine', 'fix')
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(' ', 3)
    if len(w) < 4: continue
    rows[(w[0], w[1])][w[2]] = w[3].strip()
def f(s, k):
    m = re.search(k + r'=(\S+)', s); return m.group(1) if m else ''
def eq(s): return 'STRICT_EQUAL' in s
n = mov = ent = lea = rcc = cmpc = voff = uoff = 0; attr = collections.Counter(); multi = []; lines = []
for (c, v), r in sorted(rows.items()):
    p, L = r.get(A, ''), r.get(B, ''); n += 1
    if f(r.get('fix+R11V276_OFF', ''), 'md5') == f(r.get('law', ''), 'md5'): voff += 1
    if f(r.get('fix+R11U276_OFF', ''), 'md5') == f(r.get('pristine', ''), 'md5'): uoff += 1
    if f(p, 'rc') != f(L, 'rc'): rcc += 1
    if f(p, 'cmp') != f(L, 'cmp'): cmpc += 1
    if f(p, 'md5') == f(L, 'md5'): continue
    mov += 1
    if eq(L) and not eq(p): ent += 1
    if eq(p) and not eq(L): lea += 1
    sws = [k[4:] for k in r if k.startswith('fix+R11') and k not in ('fix+R11U276_OFF', 'fix+R11V276_OFF') and f(r[k], 'md5') == f(p, 'md5')]
    for s in sws: attr[s] += 1
    if len(sws) != 1: multi.append(f'{c} {v} {sws}')
    vp = re.sub(r' md5=\S+', '', p); vl = re.sub(r' md5=\S+', '', L)
    lines.append(f'MOVER {c} {v}: {vp} -> {vl} [{",".join(sws)}]')
print('\n'.join(lines))
print(f'{A} -> {B}: case-views {n}; moving {mov}; entering STRICT_EQUAL {ent}; leaving {lea}; exit-code changes {rcc}; uhdm-cmp line changes {cmpc}')
print(f'fix+R11V276_OFF equal to law {voff}/{n}; fix+R11U276_OFF equal to pristine {uoff}/{n}')
print(f'restored by exactly one switch: {dict(attr)} ; not exactly one: {multi}')
