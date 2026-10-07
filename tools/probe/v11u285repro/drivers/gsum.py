# v11u285 gsum.py <grid.txt>: per case-view P -> L verdicts, the switches that alone return pristine bytes, and the
# grid tallies (OFF == P, moving, entering / leaving STRICT_EQUAL, exit-code and uhdm-cmp line changes). Reads grid text only.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split(); cfg, rel = f[0], f[1]
    d = dict(x.split('=',1) for x in f[3:] if '=' in x)
    if len(f) > 3 and f[3] in ('SURELOG_FAIL','SLANG_FAIL'): d = {'strict': f[3], 'rc': f[4].split('=')[1], 'md5':f[3], 'cmplines':'-'}
    rows[rel][cfg] = d
mv=ent=lv=rcch=off=lch=0
for rel in sorted(rows):
    r = rows[rel]; P, L = r['P'], r['L']
    if r.get('OFF',{}).get('md5') == P['md5']: off += 1
    if P['md5'] != L['md5']:
        mv += 1
        sw = [c for c in r if c.startswith('R11U') and r[c]['md5']==P['md5']]
        e = P['strict'] != L['strict']
        if L['strict'].startswith('STRICT_EQUAL') and not P['strict'].startswith('STRICT_EQUAL'): ent += 1
        if P['strict'].startswith('STRICT_EQUAL') and not L['strict'].startswith('STRICT_EQUAL'): lv += 1
        if P['cmplines'] != L['cmplines']: lch += 1
        print(f"{rel:40s} {P['strict']:28s} -> {L['strict']:28s} cmpl {P['cmplines']}->{L['cmplines']} rc {P['rc']}/{L['rc']} back:{','.join(s.replace('R11U285_','').replace('_OFF','') for s in sw) or 'NONE'}")
    if P['rc'] != L['rc']: rcch += 1
print(f"views={len(rows)} OFF==P {off} moving={mv} entering={ent} leaving={lv} rcchanges={rcch} cmplines_changes={lch}")
print('rc set:', sorted(set((r['P']['rc'], r['L']['rc']) for r in rows.values())))
