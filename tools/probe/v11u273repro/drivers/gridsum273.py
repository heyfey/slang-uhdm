#!/usr/bin/env python3
# r11u273 gridsum273.py <grid.txt>: per case-view the pristine and law verdicts, OFF == pristine bytes, and the
# switches whose drop alone restores pristine's bytes (the mover's attribution); then the totals.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    cfg, rel = f[0], f[1]
    kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    st = f[3] if '=' not in f[3] else kv.get('strict', '?')
    rows[rel][cfg] = (kv.get('strict', f[3] if len(f) > 3 else '?'), kv.get('md5', '-'), kv.get('rc', '?'), kv.get('cmplines', '-'))
tot = collections.Counter()
for rel in sorted(rows):
    r = rows[rel]
    P = r.get('P'); L = r.get('L'); O = r.get('OFF')
    if not P or not L: continue
    moved = P[1] != L[1]
    off_ok = O and O[1] == P[1]
    sws = [k.replace('R11U273_', '').replace('_OFF', '') for k in r if k.startswith('R11U273_') and r[k][1] == P[1] and moved]
    ent = moved and not P[0].startswith('STRICT_EQUAL') and L[0].startswith('STRICT_EQUAL')
    lea = moved and P[0].startswith('STRICT_EQUAL') and not L[0].startswith('STRICT_EQUAL')
    cmpchg = P[3] != L[3]
    tot['caseviews'] += 1; tot['moved'] += moved; tot['entering'] += ent; tot['leaving'] += lea
    tot['off_pristine'] += bool(off_ok); tot['cmp_change'] += cmpchg; tot['rc_change'] += P[2] != L[2]
    if moved: tot['attr_' + ('+'.join(sorted(sws)) or 'NONE')] += 1
    print(f"{rel} P={P[0]} L={L[0]} rcP={P[2]} rcL={L[2]} moved={int(moved)} off=pristine:{int(bool(off_ok))} by={'+'.join(sorted(sws)) or '-'}{' ENTER' if ent else ''}{' LEAVE' if lea else ''}{' CMPCHANGE' if cmpchg else ''}")
print('TOTAL', ' '.join(f'{k}={v}' for k, v in sorted(tot.items())))
