#!/usr/bin/env python3
# (v11u252) ctlsum.py <controls.txt>: the byte controls on pristine, law and fix: per case-view the movers law vs
# pristine and fix vs law, STRICT_EQUAL entered / left, and exit codes that differ between binaries.
import sys, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    kv = dict(x.split('=', 1) for x in f[2:] if '=' in x)
    d[f[0]][f[1]] = (kv.get('strict', f[2]), kv.get('rc', '-'), kv.get('md5', '-'), kv.get('cmplines', '-'))
n = mv = fx = en = lv = fen = flv = rcd = 0; out = []
for cv in sorted(d):
    t = d[cv]; p, w, x = t.get('pristine'), t.get('law'), t.get('fix')
    if not (p and w and x): out.append(f'MISSING {cv}'); continue
    n += 1
    if len({p[1], w[1], x[1]}) > 1: rcd += 1; out.append(f'RCDIFF {cv} {p[1]} {w[1]} {x[1]}')
    pe, we, xe = (v[0].startswith('STRICT_EQUAL') for v in (p, w, x))
    if p[2] != w[2]:
        mv += 1; en += (not pe and we); lv += (pe and not we)
        out.append(f'MOVER {cv:62s} {p[3]:>4s} {p[0]:30s} -> {w[3]:>4s} {w[0]:30s}' + (' ENTER' if not pe and we else '') + (' LEAVE' if pe and not we else ''))
    if x[2] != w[2]:
        fx += 1; out.append(f'FIXMOVER {cv:62s} law {w[0]} -> fix {x[0]}' + (' (fix = pristine bytes)' if x[2] == p[2] else ''))
    fen += (not pe and xe); flv += (pe and not xe)
print(f'# byte controls: {n} case-views; law vs pristine: moving {mv}, entering STRICT_EQUAL {en}, leaving {lv}; fix vs law: moving {fx}; fix vs pristine: entering {fen}, leaving {flv}; exit codes differing {rcd}')
print('\n'.join(out))
