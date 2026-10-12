#!/usr/bin/env python3
# (r11u291: copied from r11u289repro/drivers)
# r11u291 ctlsum291.py <controls.txt> <movers out>: pristine -> law per case-view of drivers/controls.sh's output
# (moving, entering / leaving STRICT_EQUAL, exit-code changes); writes the movers' rel paths. Reads only the file.
import sys, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    kv = {k: v for k, v in (x.split('=', 1) for x in f[2:] if '=' in x)}
    d[f[0]][f[1]] = kv
mov = ent = leave = rcc = 0; movers = []
for cv, x in sorted(d.items()):
    p, l = x.get('pristine'), x.get('law')
    if not p or not l: print('MISSING', cv); continue
    if p.get('rc') != l.get('rc'): rcc += 1; print('RC-CHANGE', cv, p.get('rc'), l.get('rc'))
    if p.get('md5') != l.get('md5'):
        mov += 1; movers.append(cv)
        ps = p.get('strict', '').startswith('STRICT_EQUAL'); ls = l.get('strict', '').startswith('STRICT_EQUAL')
        ent += ls and not ps
        if ps and not ls: leave += 1; print('LEAVE', cv)
        print(f"{cv:66s} rc={p.get('rc')}/{l.get('rc')} {p.get('strict','-'):26s} c{p.get('cmplines')} -> {l.get('strict','-'):26s} c{l.get('cmplines')}")
print('case-views', len(d), 'moving', mov, 'entering STRICT_EQUAL', ent, 'leaving', leave, 'exit-code changes', rcc)
open(sys.argv[2], 'w').write('\n'.join(movers) + '\n')
