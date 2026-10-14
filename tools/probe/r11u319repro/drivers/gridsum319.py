#!/usr/bin/env python3
# r11u319 gridsum319.py <grid.txt>: per case-view the pristine (P), law (L) and all-off (OFF) verdicts, the switches
# whose single removal changes the law's bytes, and the ones whose removal alone restores pristine's; prints a table
# and a summary. Reads only grid.sh output (no database).
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 4: continue
    cfg, rel = p[0], p[1]
    kv = {x.split('=', 1)[0]: x.split('=', 1)[1] for x in p[3:] if '=' in x}
    rows[rel][cfg] = (kv.get('strict', p[3]), kv.get('cmplines', '?'), kv.get('rc', '?'), kv.get('md5', '?'))
tot = mv = ent = leave = offeq = grow = rcch = 0
single = collections.Counter(); eff = collections.Counter(); multi = []
for rel in sorted(rows):
    r = rows[rel]; P, L, O = r['P'], r['L'], r['OFF']
    tot += 1
    offeq += O[3] == P[3]
    if P[2] != L[2]: rcch += 1
    sws = [k for k in r if k.startswith('R11U319_')]
    changed = [k[8:-4] for k in sws if r[k][3] != L[3]]
    for c in changed: eff[c] += 1
    restore = [k[8:-4] for k in sws if r[k][3] == P[3]]
    moving = P[3] != L[3]
    e = L[0].startswith('STRICT_EQUAL') and not P[0].startswith('STRICT_EQUAL')
    lv = P[0].startswith('STRICT_EQUAL') and not L[0].startswith('STRICT_EQUAL')
    try: g = int(L[1]) > int(P[1])
    except: g = False
    mv += moving; ent += e; leave += lv; grow += g
    if moving:
        if len(restore) == 1: single[restore[0]] += 1
        else: multi.append((rel, changed))
    print(f"{rel:48s} P={P[0]}({P[1]}) L={L[0]}({L[1]}) OFF==P={O[3]==P[3]} rc={P[2]}/{L[2]} "
          f"{'MOVE' if moving else 'same'} restore={','.join(restore) or '-'} effect={','.join(changed) or '-'}")
print(f"# case-views={tot} moving={mv} entering={ent} leaving={leave} uhdmcmp_grow={grow} rc_change={rcch} OFF==P={offeq}")
print("# restored by one switch alone: " + ', '.join(f'{k} {v}' for k, v in single.most_common()))
print(f"# needing two or more switches: {len(multi)}")
for rel, ch in multi: print(f"#   {rel}: {','.join(ch)}")
print("# switch has an effect alone (case-views): " + ', '.join(f'{k} {v}' for k, v in eff.most_common()))
