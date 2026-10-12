#!/usr/bin/env python3
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
# r11u291 gridsum291.py <grid.txt>: per case-view, pristine -> law (strict verdict, uhdm-cmp lines, exit code),
# whether R11U291_OFF restores pristine's bytes, and the switches that each alone restore them (the attribution).
# Reads only the grid file (no database, no source).
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    kv = {}
    for x in f[3:]:
        if '=' in x:
            k, v = x.split('=', 1); kv[k] = v
    rows[f[1]][f[0]] = kv
sws = None
mov = ent = leave = offbad = rcchg = 0; att = collections.Counter()
for cv, d in sorted(rows.items()):
    if sws is None:
        sws = [k for k in d if k.startswith('R11U291_')]
    P, L, O = d['P'], d['L'], d['OFF']
    if O.get('md5') != P.get('md5'):
        offbad += 1; print('OFF-NOT-PRISTINE', cv)
    if P.get('rc') != L.get('rc'):
        rcchg += 1; print('RC-CHANGE', cv, P.get('rc'), L.get('rc'))
    if P.get('md5') != L.get('md5'):
        mov += 1
        ps = P['strict'].startswith('STRICT_EQUAL'); ls = L['strict'].startswith('STRICT_EQUAL')
        ent += ls and not ps
        if ps and not ls:
            leave += 1; print('LEAVE', cv)
        who = [s for s in sws if d[s].get('md5') == P.get('md5')]
        tag = ','.join(s[8:-4] for s in who) or 'NONE'
        att[tag] += 1
        print(f"{cv:52s} rc={P['rc']}/{L['rc']} {P['strict']:26s} cmp{P['cmplines']:>3} -> {L['strict']:26s} cmp{L['cmplines']:>3}  {tag}")
print(f'case-views {len(rows)} moving {mov} entering STRICT_EQUAL {ent} leaving {leave} '
      f'OFF-not-pristine {offbad} exit-code changes {rcchg}')
print('attribution:', dict(att))
