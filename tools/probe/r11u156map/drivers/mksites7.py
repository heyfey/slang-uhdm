#!/usr/bin/env python3
"""r11u156 (mksites6.py adapted: map 6 is the previous map): the final site per cluster id. A cluster re-pinned here (pinmulti at 89d599ef: new clusters and
clusters whose example object changed since map 6) takes the new pin where the gdb run wrote the reference
database byte for byte (db=SAME) and the mint is a source frame; map 6's pin where the run's database differed
(the UVM order coin) or the new mint is UHDM's DeepClone (an --elabuhdm testflags row) while map 6 pinned a
source frame. Every other cluster keeps map 6's site (final.py marks it [r11u150map pin]). Map 6's decoded
notes ([DECODED ...], [NOTE ...], [pass-...]) ride on the site; this map's decodes (decoded_sites.json) too.
Args: <pins.txt> <sites_new.json> <map6 dir> <decoded json of this map> <out sites.json>"""
import json, re, csv, sys, collections
PINS, SN, M5, DEC, OUT = sys.argv[1:6]
S = json.load(open(SN)) if SN != '-' else {}
O = {r['cluster_id']: r for r in csv.DictReader(open(f'{M5}/cluster_index.csv'))}
dn = json.load(open(DEC))
diff = set()
if PINS != '-':
    for l in open(PINS):
        m = re.match(r'^== (\S+) .* db=(\w+)', l)
        if m and m.group(2) == 'DIFF': diff.add(m.group(1))
def split(site):
    """map 6 site -> (the pin chain, [note brackets])"""
    parts = re.split(r' (?=\[)', site); base = parts[0]; notes = []
    for p in parts[1:]:
        if re.match(r'\[(DECODED|NOTE|pass-)', p): notes.append(p)
    return base, notes
mint = lambda s: s.split(' | ')[0].split(' < ')[0].split(' (')[0]
out = {}; how = {}
for k, v in S.items():
    new = v['site']; old, notes = split(O[k]['site']) if k in O else ('', [])
    if k in diff and old and old != '-':
        s = old + ' [r11u150map pin; the 89d599ef gdb run wrote a different database (UVM order coin)]'; how[k] = 'map5-coin'
    elif new.startswith('UHDM library') and old and old != '-' and not old.startswith('UHDM'):
        s = old + ' [r11u150map pin; the 89d599ef example row is an --elabuhdm testflags row whose object UHDM DeepClone minted from ours]'; how[k] = 'map5-elab'
    elif new.startswith('NOT PINNED') and old and old != '-':
        s = old + ' [r11u150map pin; the 89d599ef run caught no mint frame]'; how[k] = 'map5-nopin'
    else:
        s = new
        if old and old != '-' and mint(old) != mint(new): s += ' [r11u150map pin (other example): ' + old[:160] + ']'; how[k] = 'new-differs'
        else: how[k] = 'new-same-mint' if old and old != '-' else 'new'
    out[k] = s + ''.join(' ' + n for n in notes)
for k, v in dn.items():
    if k not in out:
        base = O[k]['site'] + ' [r11u150map pin]' if k in O and O[k]['site'] not in ('', '-') else v.get('site', '-')
        out[k] = base
    out[k] += ' [' + v['note'] + ']'
json.dump(out, open(OUT, 'w'), indent=1)
print(len(out), dict(collections.Counter(how.values())))
