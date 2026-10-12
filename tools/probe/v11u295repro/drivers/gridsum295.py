#!/usr/bin/env python3
# (v11u295: copied from r11u295repro/drivers)
# r11u295 gridsum295.py <grid.txt>: one line per case-view: P and L strict verdicts with exit codes, whether L moved
# (md5 differs from P), whether OFF restores P's bytes, and which single switch restores P's bytes.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    cfg, cv = f[0], f[1]
    d = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    if 'SURELOG_FAIL' in l or 'SLANG_FAIL' in l: d['strict'] = f[3] if len(f) > 3 else '?'
    rows[cv][cfg] = d
mv = ent = leave = 0
for cv in sorted(rows):
    r = rows[cv]; P = r.get('P', {}); L = r.get('L', {}); O = r.get('OFF', {})
    moved = P.get('md5') != L.get('md5')
    sw = [k for k in r if k.startswith('R11U295_') and r[k].get('md5') == P.get('md5')] if moved else []
    pe = P.get('strict', '').startswith('STRICT_EQUAL'); le = L.get('strict', '').startswith('STRICT_EQUAL')
    mv += moved; ent += (moved and le and not pe); leave += (pe and not le)
    print(f"{cv:60s} P={P.get('strict','?')}(rc={P.get('rc','?')},cl={P.get('cmplines','?')}) L={L.get('strict','?')}(rc={L.get('rc','?')},cl={L.get('cmplines','?')}) "
          f"{'MOVED' if moved else 'same'} OFFrestores={'yes' if O.get('md5') == P.get('md5') else 'NO'} by={','.join(s.replace('R11U295_','').replace('_OFF','') for s in sw) or '-'}")
print(f"TOTAL case-views={len(rows)} moved={mv} entering_STRICT_EQUAL={ent} leaving_STRICT_EQUAL={leave}")
