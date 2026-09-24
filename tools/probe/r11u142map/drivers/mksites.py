#!/usr/bin/env python3
"""r11u142: the final site per cluster id. New pins (pinmulti at a7bee711, sites.py) where the gdb run
wrote the reference database byte for byte (db=SAME) and the mint is a source frame; map 4's pin where the
run's database differed (the UVM order coin) or where the new example row is a --elabuhdm testflags row
minted by UHDM's DeepClone while map 4 pinned a source frame; map 4's decoded notes carried
(evidence/decoded_sites.json of r11u138map) plus this map's (evidence/decoded_sites.json here).
Args: <pins_new.txt> <sites_new.json> <map4 dir> <decoded json of this map> <out sites.json>"""
import json, re, csv, sys
PINS, SN, M4, DEC, OUT = sys.argv[1:6]
S = json.load(open(SN))
O = {r['cluster_id']: r for r in csv.DictReader(open(f'{M4}/cluster_index.csv'))}
d4 = json.load(open(f'{M4}/evidence/decoded_sites.json')); dn = json.load(open(DEC))
diff = set()
for l in open(PINS):
    m = re.match(r'^== (\S+) .* db=(\w+)', l)
    if m and m.group(2) == 'DIFF': diff.add(m.group(1))
strip = lambda s: re.sub(r' \[.*', '', s)
mint = lambda s: s.split(' | ')[0].split(' < ')[0].split(' (')[0]
out = {}; how = {}
for k, v in S.items():
    new = v['site']; old = strip(O[k]['site']) if k in O else ''
    if k in diff and old and old != '-':
        out[k] = old + ' [r11u138map pin; the a7bee711 gdb run wrote a different database (UVM order coin)]'; how[k] = 'map4-coin'
    elif new.startswith('UHDM library') and old and old != '-' and not old.startswith('UHDM'):
        out[k] = old + ' [r11u138map pin; the a7bee711 example row is a --elabuhdm testflags row whose object UHDM DeepClone minted from ours]'; how[k] = 'map4-elab'
    else:
        out[k] = new
        if old and old != '-' and mint(old) != mint(new): out[k] += ' [r11u138map pin (other example): ' + old[:160] + ']'; how[k] = 'new-differs'
        else: how[k] = 'new'
for src in (d4, dn):
    for k, v in src.items():
        base = out.get(k) or (strip(O[k]['site']) if k in O else v.get('site', '-'))
        if v.get('site') and k not in out and not base: base = v['site']
        if v.get('note'): base += ' [' + v['note'] + ']'
        out[k] = base
json.dump(out, open(OUT, 'w'), indent=1)
import collections; print(len(out), dict(collections.Counter(how.values())))
