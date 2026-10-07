# v11u285 ctlsum.py <controls.txt> <movers out>: the byte-control tallies (pristine vs law per case-view) from
# case.sh lines; writes the movers list for the away census. Reads controls text only.
import sys, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    rel, tag = f[0], f[1]
    kv = dict(x.split('=',1) for x in f[2:] if '=' in x)
    if f[2] in ('SURELOG_FAIL','SLANG_FAIL'): kv = {'strict': f[2], 'md5': f[2], 'cmplines': '-', 'rc': kv.get('rc')}
    d[rel][tag] = kv
mv=ent=lv=rc=cl=0; movers=[]; rcs=collections.Counter()
for rel, r in sorted(d.items()):
    if 'pristine' not in r or 'law' not in r: print('INCOMPLETE', rel); continue
    P, L = r['pristine'], r['law']
    rcs[(P['rc'], L['rc'])] += 1
    if P['rc'] != L['rc']: rc += 1
    if P['md5'] != L['md5']:
        mv += 1; movers.append(rel)
        if L['strict'].startswith('STRICT_EQUAL') and not P['strict'].startswith('STRICT_EQUAL'): ent += 1; print('ENTER', rel, P['strict'], '->', L['strict'])
        if P['strict'].startswith('STRICT_EQUAL') and not L['strict'].startswith('STRICT_EQUAL'): lv += 1; print('LEAVE', rel)
        if P['cmplines'] != L['cmplines']: cl += 1; print('CMPLINES', rel, P['cmplines'], L['cmplines'])
        if P['strict'] != L['strict'] and not L['strict'].startswith('STRICT_EQUAL'): print('STRICTCHANGE', rel, P['strict'], '->', L['strict'])
print(f'case-views={len(d)} moving={mv} entering={ent} leaving={lv} rc_changes={rc} cmplines_changes={cl}')
print('rc pairs', dict(rcs))
open(sys.argv[2], 'w').write('\n'.join(movers) + '\n')
