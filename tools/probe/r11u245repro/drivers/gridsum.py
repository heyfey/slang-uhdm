#!/usr/bin/env python3
# (r11u245: copied from r11u243repro/drivers; the summary line names R11U245_OFF)
# (r11u243: copied from r11u241repro/drivers)
# (r11u241: copied from r11u238repro/drivers)
"""gridsum.py <grid.txt>: per case-view pristine -> law verdicts (cmp lines, exit codes), OFF==pristine, per-switch
reverts, entering/leaving STRICT_EQUAL.  Reads only grid.sh's own output lines (no database)."""
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    rows[f[0]][f[1]] = dict(x.split('=', 1) for x in f[2:] if '=' in x)
sws = sorted({k for r in rows.values() for k in r if k.startswith('law-')})
off = 0; rev = collections.Counter(); ent = lev = mov = 0
for c, r in sorted(rows.items()):
    P, L, O = r['pristine'], r['law'], r['lawOFF']
    off += O.get('md5') == P.get('md5')
    mov += L.get('md5') != P.get('md5')
    for s in sws: rev[s[4:]] += r[s].get('md5') != L.get('md5')
    pe = 'STRICT_EQUAL' in P.get('strict', ''); le = 'STRICT_EQUAL' in L.get('strict', '')
    ent += le and not pe; lev += pe and not le
    print(f"| {c} | {P.get('strict','?')} cmp {P.get('cmplines','-')} rc {P.get('rc')} | {L.get('strict','?')} cmp {L.get('cmplines','-')} rc {L.get('rc')} | {'moved' if L.get('md5') != P.get('md5') else 'same'} |")
print(f"case-views {len(rows)}; R11U245_OFF == pristine {off}; moved {mov}; entering STRICT_EQUAL {ent}; leaving {lev}; per-switch reverts {dict(rev)}")
