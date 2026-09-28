#!/usr/bin/env python3
"""r11u197 (map 10's mksites10.py re-based: map 10 is the previous map): the final site per cluster id. A cluster
re-pinned here (pinmulti at 4a65840e: new clusters and clusters whose example object changed since map 10, among the
clusters with >= 3 row-modes, first on a fail row, or >= 40 probe cases) takes the new pin where the gdb run wrote
the reference database byte for byte (db=SAME), or where it did not (the UVM order coin) but the object at the pinned
rank in the gdb run's database carries the example's name, file and span (db=DIFF-rankverified). Every other cluster
keeps map 10's site (report11.py marks it [r11u189map pin]). Decoded notes ride on the site.
Args: <pins.txt> <sites_new.json> <map8 dir> <out sites.json>"""
import json, re, csv, sys, collections
PINS, SN, M8D, OUT = sys.argv[1:5]
S = json.load(open(SN))
O = {r['cluster_id']: r for r in csv.DictReader(open(f'{M8D}/cluster_index.csv'))}
state = {}
for l in open(PINS):
    m = re.match(r'^== (\S+) .* db=(\S+)', l)
    if m: state[m.group(1)] = m.group(2)
def split(site):
    parts = re.split(r' (?=\[)', site); base = parts[0]; notes = [p for p in parts[1:] if re.match(r'\[(DECODED|NOTE|pass-)', p)]
    return base, notes
mint = lambda s: s.split(' | ')[0].split(' < ')[0].split(' (')[0]
out = {}; how = {}
for k, v in S.items():
    new = v['site']; old, notes = split(O[k]['site']) if k in O else ('', [])
    old = re.sub(r' \[r11u1\d\dmap pin[^\]]*\]', '', old)
    if state.get(k) == 'DIFF' and old and old != '-':
        s = old + ' [r11u189map pin; the 4a65840e gdb run wrote a different database (UVM order coin)]'; how[k] = 'map8-coin'
    elif new.startswith('UHDM library') and old and old != '-' and not old.startswith('UHDM'):
        s = old + ' [r11u189map pin; the 4a65840e example row is an --elabuhdm testflags row whose object UHDM DeepClone minted from ours]'; how[k] = 'map8-elab'
    elif new.startswith('NOT PINNED') and old and old != '-':
        s = old + ' [r11u189map pin; the 4a65840e run caught no mint frame]'; how[k] = 'map8-nopin'
    else:
        s = new + (' [r11u197 pin, db=DIFF (UVM order coin), rank verified]' if state.get(k) == 'DIFF-rankverified' else ' [r11u197 pin, db=DIFF (UVM order coin), rank NOT verified]' if state.get(k) == 'DIFF' else ' [r11u197 pin]')
        if old and old != '-' and mint(old) != mint(new): s += ' [r11u189map pin (other example): ' + old[:160] + ']'; how[k] = 'new-differs'
        else: how[k] = 'new-same-mint' if old and old != '-' else 'new'
    out[k] = s + ''.join(' ' + n for n in notes)
json.dump(out, open(OUT, 'w'), indent=1)
print(len(out), dict(collections.Counter(how.values())))
