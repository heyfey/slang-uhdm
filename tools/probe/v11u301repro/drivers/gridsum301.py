#!/usr/bin/env python3
# (v11u301: copied from r11u301repro/drivers)
# r11u301 gridsum301.py (from r11u299 gridsum299.py) <grid.txt>: per case-view the pristine (P) and law (L) verdicts with exit codes, whether OFF
# (R11U301_OFF) gives P's bytes and exit code, which single switch restores P's bytes, and the totals.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 3: continue
    cfg, rel = p[0], p[1]
    kv = dict(x.split('=', 1) for x in p[3:] if '=' in x)
    st = kv.get('strict', p[3] if len(p) > 3 else '?')
    if 'SURELOG_FAIL' in l: st = 'SURELOG_FAIL'
    if 'SLANG_FAIL' in l: st = 'SLANG_FAIL'
    rows[rel][cfg] = (kv.get('md5', '-'), st, kv.get('rc', '?'), kv.get('cmplines', '-'))
mov = enter = leave = offok = 0; attr = collections.Counter(); n = 0
for rel in sorted(rows):
    r = rows[rel]; P = r.get('P'); L = r.get('L'); O = r.get('OFF')
    if not P or not L: continue
    n += 1
    moved = P[0] != L[0] or P[2] != L[2]
    if O and O[0] == P[0] and O[2] == P[2]: offok += 1
    sw = [c for c in r if c not in ('P', 'L', 'OFF') and r[c][0] == P[0] and r[c][2] == P[2]] if moved else []
    if moved:
        mov += 1
        if 'STRICT_EQUAL' in L[1] and 'STRICT_EQUAL' not in P[1]: enter += 1
        if 'STRICT_EQUAL' in P[1] and 'STRICT_EQUAL' not in L[1]: leave += 1
        attr[' + '.join(s.replace('R11U301_', '').replace('_OFF', '') for s in sw) or 'none-alone'] += 1
    print(f"{rel:58s} P {P[1]} rc={P[2]} cmp={P[3]} | L {L[1]} rc={L[2]} cmp={L[3]} | {'MOVES' if moved else 'same'} | OFF={'P' if O and O[0]==P[0] and O[2]==P[2] else 'DIFF'} | restored by: {','.join(s.replace('R11U301_','').replace('_OFF','') for s in sw) or '-'}")
print(f"case-views {n}: moving {mov}, entering STRICT_EQUAL {enter}, leaving {leave}, OFF == P {offok} of {n}")
print('attribution:', dict(attr))
