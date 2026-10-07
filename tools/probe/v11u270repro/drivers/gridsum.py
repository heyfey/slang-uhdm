#!/usr/bin/env python3
# v11u270: summarize drivers/grid.sh output: per case-view pris -> law verdict, OFF == pris, and the single switch
# that returns each mover to pristine bytes.
import sys, collections
d = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split()
    d[w[0]][w[1]] = dict(x.split('=', 1) for x in w[2:] if '=' in x)
mv = ent = lea = offok = cmpch = rcbad = 0; attr = collections.Counter(); multi = []
for cv in sorted(d):
    t = d[cv]; P, L, O = t['pris'], t['law'], t['off']
    rcbad += sum(1 for k in t.values() if k.get('rc') != '0')
    offok += O.get('md5') == P.get('md5')
    if P.get('cmplines') != L.get('cmplines'): cmpch += 1
    moved = P.get('md5') != L.get('md5')
    sw = [k for k in t if k not in ('pris', 'law', 'off', 'INSIDEQUAL') and t[k].get('md5') == P.get('md5')]
    if moved:
        mv += 1
        ent += 'STRICT_EQUAL' in L.get('strict', '') and 'STRICT_EQUAL' not in P.get('strict', '')
        lea += 'STRICT_EQUAL' in P.get('strict', '') and 'STRICT_EQUAL' not in L.get('strict', '')
        if len(sw) == 1: attr[sw[0]] += 1
        else: multi.append((cv, sw))
    print(f"{cv:42s} {P.get('strict','?'):30s} -> {L.get('strict','?'):30s} {'MOVED by '+','.join(sw) if moved else ''}")
print(f'case-views {len(d)} moving {mv} entering {ent} leaving {lea} cmplines_changes {cmpch} OFF==pris {offok} nonzero_rc {rcbad}')
print('attribution', dict(attr), 'multi', multi)
