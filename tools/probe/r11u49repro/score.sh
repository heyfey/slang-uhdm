#!/bin/bash
# r11u49 GRID SCORER — for each arm, run shape.py on the golden dump and on the
# PRISTINE and LAW dumps, and score every (listing, param) cell three ways:
#   TO    = law agrees with golden where pristine did not
#   AWAY  = law disagrees with golden where pristine agreed
#   STILL = both disagree      SAME = both agree
# usage: score.sh <armdir-pris> <armdir-law>   (each holding g.dump / o.dump)
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
P=${1:?pristine arm dir}; L=${2:?law arm dir}
python3 "$HERE/shape.py" "$P/g.dump" > /tmp/r11u49_sc.g.$$ 2>&1
python3 "$HERE/shape.py" "$P/o.dump" > /tmp/r11u49_sc.p.$$ 2>&1
python3 "$HERE/shape.py" "$L/o.dump" > /tmp/r11u49_sc.l.$$ 2>&1
python3 - "$P" /tmp/r11u49_sc.g.$$ /tmp/r11u49_sc.p.$$ /tmp/r11u49_sc.l.$$ <<'PY'
import sys
arm, g, p, l = sys.argv[1:5]
def load(f):
    d = {}
    for ln in open(f):
        if ln.startswith('## '): continue
        t = ln.split(None, 3)
        if len(t) < 4: continue
        d[(t[0], t[1], t[2])] = t[3].strip()
    return d
G, P, L = load(g), load(p), load(l)
keys = sorted(set(G) | set(P) | set(L))
to = away = still = same = 0
for k in keys:
    gv, pv, lv = G.get(k, 'ABSENT'), P.get(k, 'ABSENT'), L.get(k, 'ABSENT')
    if lv == gv and pv != gv: to += 1;   tag = 'TO'
    elif lv != gv and pv == gv: away += 1; tag = 'AWAY'
    elif lv != gv: still += 1; tag = 'STILL'
    else: same += 1; tag = 'SAME'
    if tag in ('TO', 'AWAY', 'STILL'):
        print('  %-5s %-16s %-24s %-14s G[%s] P[%s] L[%s]' % (tag, k[0], k[1], k[2], gv, pv, lv))
print('ARM %s  TO %d  AWAY %d  STILL %d  SAME %d' % (arm.rstrip('/').split('/')[-1], to, away, still, same))
PY
rm -f /tmp/r11u49_sc.g.$$ /tmp/r11u49_sc.p.$$ /tmp/r11u49_sc.l.$$
