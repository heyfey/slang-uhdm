#!/usr/bin/env python3
# r11u297 gridsum297.py <grid.txt>: per case-view, P vs L (moving, entering/leaving STRICT_EQUAL, exit codes),
# OFF == P bytes, and which single switch restores P's bytes for each mover.
import re, sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 4: continue
    cfg, cv = f[0], f[1]
    md5 = re.search(r'md5=(\S+)', l); rc = re.search(r'rc=(\d+)', l); st = re.search(r'strict=(\S+)', l)
    rows[cv][cfg] = (md5.group(1) if md5 else 'NONE:' + (f[3] if len(f) > 3 else ''), rc.group(1) if rc else '?',
                     st.group(1) if st else f[3])
mov = ent = lea = offbad = rcchg = 0; per = collections.Counter(); multi = []
for cv, d in sorted(rows.items()):
    P, L, O = d['P'], d['L'], d['OFF']
    if O[0] != P[0] or O[1] != P[1]: offbad += 1; print('OFF!=P', cv, P, O)
    if P[1] != L[1]: rcchg += 1
    if P[0] != L[0] or P[1] != L[1]:
        mov += 1
        e = L[2].startswith('STRICT_EQUAL') and not P[2].startswith('STRICT_EQUAL')
        lv = P[2].startswith('STRICT_EQUAL') and not L[2].startswith('STRICT_EQUAL')
        ent += e; lea += lv
        sw = [k for k in d if k.startswith('R11U') and d[k][0] == P[0] and d[k][1] == P[1]]
        if len(sw) == 1: per[sw[0]] += 1
        else: multi.append(cv)
        print('MOVE %-48s rc %s->%s  %s -> %s  %s' % (cv, P[1], L[1], P[2], L[2], ','.join(sw) or 'NONE'))
print('case-views %d moving %d entering %d leaving %d rc-changes %d OFF!=P %d' % (len(rows), mov, ent, lea, rcchg, offbad))
print('single-switch', dict(per), 'not-single', multi)
