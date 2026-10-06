#!/usr/bin/env python3
# (v11u252: from r11u252repro/drivers/gridsum.py, with the fix columns) gridsum.py <grid.txt>: per case-view
# pristine -> law (cmp lines, strict verdict, rc), law + R11U252_OFF == pristine, the switches that revert the law's
# bytes, and when present fix (its verdict, whether its bytes equal the law's) and fix + R11V252_OFF == law.
import sys, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    kv = dict(x.split('=', 1) for x in f[2:] if '=' in x)
    st = kv.get('strict', f[2]).replace('STRICT_', 'S_').replace('NOT_EQUAL_stage1', 'stage1')
    d[f[0]][f[1]] = (kv.get('cmplines', '-'), st, kv.get('rc', '-'), kv.get('md5', '-'))
fuok = off_ok = n = enter = leave = fx_n = fx_eqlaw = fvoff_ok = fenter = fleave = 0; rcbad = []
for cv in sorted(d):
    t = d[cv]; p = t.get('pristine'); w = t.get('law'); o = t.get('lawOFF'); fx = t.get('fix'); fv = t.get('fixVOFF')
    if not (p and w and o): print(cv, 'MISSING'); continue
    n += 1; off_ok += o[3] == p[3]
    sws = [k[4:].replace('R11U252_', '').replace('_OFF', '') for k, v in t.items() if k.startswith('law-') and v[3] != w[3]]
    pe = p[1].startswith('S_EQUAL'); we = w[1].startswith('S_EQUAL')
    enter += (not pe and we); leave += (pe and not we)
    for k, v in t.items():
        if v[2] not in ('0', '-'): rcbad.append((cv, k, v[2]))
    fxs = ''
    if fx:
        fx_n += 1; fx_eqlaw += fx[3] == w[3]
        fe = fx[1].startswith('S_EQUAL'); fenter += (not pe and fe); fleave += (pe and not fe)
        if fv: fvoff_ok += fv[3] == w[3]
        fu = t.get('fixUOFF'); fuok += bool(fu and fu[3] == p[3])
        vsw = [k[4:].replace('R11V252_', '').replace('_OFF', '') for k, v in t.items() if k.startswith('fix-') and v[3] != fx[3]]
        fxs = f" fix={'law' if fx[3]==w[3] else ('pristine' if fx[3]==p[3] else 'OWN')} {fx[1]} vOFF={'ok' if fv and fv[3]==w[3] else 'DIFF'} uOFF={'ok' if fu and fu[3]==p[3] else 'DIFF'} vsw:{','.join(sorted(vsw)) or '-'}"
    mv = 'same' if p[3] == w[3] else 'MOVED'
    print(f"{cv:44s} {p[0]:>4s} {p[1]:24s} rc{p[2]} -> {w[0]:>4s} {w[1]:24s} rc{w[2]} {mv:5s} off={'ok' if o[3]==p[3] else 'DIFF'} sw:{','.join(sorted(sws)) or '-'}{fxs}")
print(f"# case-views {n}; R11U252_OFF == pristine on {off_ok}/{n}; entering STRICT_EQUAL {enter}; leaving {leave}; non-zero rc lines {len(rcbad)}")
if fx_n: print(f"# fix: case-views {fx_n}; fix bytes == law on {fx_eqlaw}; fix + R11V252_OFF == law on {fvoff_ok}; fix + R11U252_OFF == pristine on {fuok}; fix entering STRICT_EQUAL {fenter}; leaving {fleave}")
for x in rcbad: print('# rc', *x)
