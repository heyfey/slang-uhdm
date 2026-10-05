#!/usr/bin/env python3
# (v11u244) gridsum.py <grid.txt>: per case-view the pristine and law verdicts, whether R11U244_OFF writes pristine's
# bytes, and which switches revert the law's bytes to pristine's.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 3: continue
    kv = dict(x.split('=', 1) for x in p[2:] if '=' in x)
    kv['raw'] = l.strip()
    rows[p[0]][p[1]] = kv
tot = collections.Counter()
for cv in sorted(rows):
    r = rows[cv]; P = r.get('pristine', {}); L = r.get('law', {})
    if not P.get('md5') or not L.get('md5'):
        print(cv, 'INCOMPLETE', [x['raw'] for x in r.values()][:2]); continue
    off = r.get('lawOFF', {}).get('md5') == P['md5']
    rev = [k.replace('law-R11U244_', '').replace('_OFF', '') for k, v in r.items() if k.startswith('law-') and v.get('md5') == P['md5'] and L['md5'] != P['md5']]
    moved = L['md5'] != P['md5']
    tot['views'] += 1; tot['moved'] += moved; tot['offpristine'] += off
    if not P['strict'].startswith('STRICT_EQUAL') and L['strict'].startswith('STRICT_EQUAL'): tot['enter'] += 1
    if P['strict'].startswith('STRICT_EQUAL') and not L['strict'].startswith('STRICT_EQUAL'): tot['LEAVE'] += 1
    if int(L['cmplines']) > int(P['cmplines']): tot['CMPUP'] += 1
    print(f"{cv:40s} P[{P['strict']} c{P['cmplines']} rc{P['rc']}] L[{L['strict']} c{L['cmplines']} rc{L['rc']}] moved={int(moved)} off={int(off)} rev={','.join(rev)}")
print(dict(tot))
