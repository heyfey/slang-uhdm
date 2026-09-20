#!/usr/bin/env bash
# r11u69 CELL SCORER — golden-vs-ours cont_assign shapes, per arm, per section.
# usage: r11u69_cell.sh <arm> [tag] [section]
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GRID=${GRID:?set GRID to a writable copy of this dir's grid/}
a=${1:?arm}; TAG=${2:-pris}; SEC=${3:-elab}
d=$GRID/$a

python3 $HERE/shapes69.py $d/gold.$TAG.dump $SEC | sed 's|'"$d"'/||' > /tmp/r11u69_g.$$
python3 $HERE/shapes69.py $d/ours.$TAG.dump $SEC | sed 's|'"$d"'/||' > /tmp/r11u69_o.$$
echo "== $a [$TAG/$SEC] =="
python3 - /tmp/r11u69_g.$$ /tmp/r11u69_o.$$ <<'PY'
import sys
g = [l.rstrip('\n') for l in open(sys.argv[1])]
o = [l.rstrip('\n') for l in open(sys.argv[2])]
def key(l):
    f = l.split('\t')
    return (f[0], f[1], f[2])
gm = {}
for l in g: gm.setdefault(key(l), []).append(l)
om = {}
for l in o: om.setdefault(key(l), []).append(l)
keys = sorted(set(gm) | set(om))
ne = 0
for k in keys:
    gl = gm.get(k, ['<MISSING>'])
    ol = om.get(k, ['<MISSING>'])
    for i in range(max(len(gl), len(ol))):
        gs = gl[i].split('\t', 3)[3] if i < len(gl) and '\t' in gl[i] else str(gl[i] if i < len(gl) else '<MISSING>')
        os_ = ol[i].split('\t', 3)[3] if i < len(ol) and '\t' in ol[i] else str(ol[i] if i < len(ol) else '<MISSING>')
        mark = 'SAME  ' if gs == os_ else 'DIFF  '
        if gs != os_: ne += 1
        print(f'{mark}{k[0] or "<module>"} {k[1]} {k[2]}')
        if gs != os_:
            print(f'        G: {gs}')
            print(f'        O: {os_}')
print(f'CELLS={len(keys)} DIFF={ne}')
PY
rm -f /tmp/r11u69_g.$$ /tmp/r11u69_o.$$
