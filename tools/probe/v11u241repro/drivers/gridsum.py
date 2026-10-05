#!/usr/bin/env python3
# gridsum.py <grid.txt>: per case-view, pristine / law / fix verdict + whether bytes moved; R11U241_OFF == pristine;
# which switches revert the law's bytes. Lines without rc= are flagged.
import sys, collections
rows = collections.defaultdict(dict)
bad = 0
for l in open(sys.argv[1]):
    f = l.split()
    if 'rc=' not in l: bad += 1; print('NO_RC', l.strip()); continue
    kv = {x.split('=')[0]: x.split('=', 1)[1] for x in f[2:] if '=' in x}
    rows[f[0]][f[1]] = kv
def v(k):
    if 'strict' not in k: return 'FAIL'
    s = k['strict']; return ('S1' if 'stage1' in s else s.replace('STRICT_', '').split('_objects')[0]) + ' c' + k['cmplines']
tot = collections.Counter()
for cv, d in rows.items():
    p, L = d.get('pristine', {}), d.get('law', {})
    off_ok = d.get('lawOFF', {}).get('md5') == p.get('md5')
    rev = [t.split('R11U241_')[1].replace('_OFF', '') for t, k in d.items() if t.startswith('law-') and k.get('md5') == p.get('md5') and L.get('md5') != p.get('md5')]
    rcs = sorted({k.get('rc') for k in d.values()})
    fx = d.get('fix')
    mv = 'moved' if L.get('md5') != p.get('md5') else 'same'
    print(f"{cv:14} P[{v(p)}] L[{v(L)}]" + (f" F[{v(fx)}] {'fmoved' if fx.get('md5')!=L.get('md5') else 'fsame'}" if fx else '') + f" {mv} OFF={'pris' if off_ok else 'DIFF'} rc={','.join(rcs)} revert={','.join(rev)}")
    tot['views'] += 1; tot['off_ok'] += off_ok; tot[mv] += 1
    pe, le = 'EQUAL' in v(p) and 'NOT' not in v(p), 'EQUAL' in v(L) and 'NOT' not in v(L)
    if not pe and le: tot['enter_SE'] += 1
    if pe and not le: tot['LEAVE_SE'] += 1
    if p.get('cmplines') == '0' and L.get('cmplines') != '0': tot['LEAVE_CMP'] += 1
print(dict(tot), 'no_rc_lines', bad)
