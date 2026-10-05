#!/usr/bin/env python3
"""(v11u246) vgridsum.py <vgrid.txt>: per case-view pristine / law / fix verdicts; fix+R11V246_OFF == law,
fix+R11U246_OFF == pristine; entering / leaving STRICT_EQUAL fix vs pristine and fix vs law; uhdm-cmp line counts.
Reads only vgrid.sh's own lines (no database)."""
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    rows[f[0]][f[1]] = dict(x.split('=', 1) for x in f[2:] if '=' in x)
n = len(rows); voff = uoff = pe = 0; ent = lev = entL = levL = movFL = movFP = cmpup = 0; nz = []
for c, r in sorted(rows.items()):
    P, L, F = r['pristine'], r['law'], r['fix']
    voff += r['fixVOFF'].get('md5') == L.get('md5'); uoff += r['fixUOFF'].get('md5') == P.get('md5')
    pe += r['fixPAEVALOFF'].get('md5') == L.get('md5')
    movFL += F.get('md5') != L.get('md5'); movFP += F.get('md5') != P.get('md5')
    eq = lambda x: 'STRICT_EQUAL' in x.get('strict', '')
    ent += eq(F) and not eq(P); lev += eq(P) and not eq(F); entL += eq(F) and not eq(L); levL += eq(L) and not eq(F)
    if int(F.get('cmplines', '0') or 0) > int(P.get('cmplines', '0') or 0): cmpup += 1
    for t, x in r.items():
        if x.get('rc', '0') != '0': nz.append(f'{c}:{t}:rc={x.get("rc")}')
    if F.get('md5') != L.get('md5') or L.get('md5') != P.get('md5'):
        print(f"| {c} | {P.get('strict','?')} cmp {P.get('cmplines','-')} | {L.get('strict','?')} cmp {L.get('cmplines','-')} | {F.get('strict','?')} cmp {F.get('cmplines','-')} | {'fix!=law' if F.get('md5') != L.get('md5') else 'fix==law'} |")
print(f"case-views {n}; fix+R11V246_OFF == law {voff}; fix+R11V246_PAEVALCTX_OFF == law {pe}; fix+R11U246_OFF == pristine {uoff}; "
      f"fix != law {movFL}; fix != pristine {movFP}; vs pristine entering STRICT_EQUAL {ent} leaving {lev}; vs law entering {entL} leaving {levL}; "
      f"uhdm-cmp count rising vs pristine {cmpup}; non-zero exits {len(nz)} {sorted(set(x.split(':')[0] for x in nz))}")
