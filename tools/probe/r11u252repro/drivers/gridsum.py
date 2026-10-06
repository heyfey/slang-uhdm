#!/usr/bin/env python3
# (r11u250) gridsum.py <grid.txt>: per case-view pristine -> law (cmp lines, strict verdict, rc), whether law +
# R11U252_OFF reproduces pristine's bytes, and which switches revert the law's bytes (sw: column).
import sys, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    kv = dict(x.split('=', 1) for x in f[2:] if '=' in x)
    st = kv.get('strict', f[2]).replace('STRICT_', 'S_').replace('NOT_EQUAL_stage1', 'stage1')
    d[f[0]][f[1]] = (kv.get('cmplines', '-'), st, kv.get('rc', '-'), kv.get('md5', '-'))
off_ok = 0; n = 0; enter = leave = 0; rcbad = []
for cv in sorted(d):
    t = d[cv]; p = t.get('pristine'); w = t.get('law'); o = t.get('lawOFF')
    if not (p and w and o): print(cv, 'MISSING'); continue
    n += 1
    if o[3] == p[3]: off_ok += 1
    sws = [k[4:].replace('R11U252_', '').replace('_OFF', '') for k, v in t.items() if k.startswith('law-') and v[3] != w[3]]
    pe = p[1].startswith('S_EQUAL'); we = w[1].startswith('S_EQUAL')
    enter += (not pe and we); leave += (pe and not we)
    for k, v in t.items():
        if v[2] not in ('0', '-'): rcbad.append((cv, k, v[2]))
    mv = 'same' if p[3] == w[3] else 'MOVED'
    print(f"{cv:42s} {p[0]:>4s} {p[1]:24s} rc{p[2]} -> {w[0]:>4s} {w[1]:24s} rc{w[2]} {mv:5s} off={'ok' if o[3]==p[3] else 'DIFF'} sw:{','.join(sorted(sws)) or '-'}")
print(f"# case-views {n}; R11U252_OFF == pristine on {off_ok}/{n}; entering STRICT_EQUAL {enter}; leaving {leave}; non-zero rc lines {len(rcbad)}")
for x in rcbad: print('# rc', *x)
