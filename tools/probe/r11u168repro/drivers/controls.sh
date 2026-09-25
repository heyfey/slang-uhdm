#!/bin/bash
# controls.sh <law bin> <pristine bin> <out dir>: every case of the landed laws' evidence dirs (the brief's byte
# controls) with both binaries; per dir a pris/law listing, then the byte movers with both verdicts.
D=$(cd "$(dirname "$0")" && pwd); TP=$D/../..; L=$1; P=$2; O=$3; mkdir -p $O
export GW=${GW:-/tmp/r11u168_gL}
for d in r11u118repro r11v11u118repro r11u119repro r11u120repro r11v120repro r11u124repro r11v124repro r11u125repro r11v125repro r11u130repro r11v130repro r11u131repro r11v131repro r11u152repro v11u152repro r11u155repro v11u155repro r11u160repro v11u160repro r11u164repro v11u164repro; do
  bash $D/grid.sh $TP/$d pris $P > $O/$d.pris
  bash $D/grid.sh $TP/$d law $L > $O/$d.law
done
python3 - $O <<'PY'
import sys, glob, os
o = sys.argv[1]; tot = mv = 0; lines = []
for f in sorted(glob.glob(o + '/*.pris')):
    d = os.path.basename(f)[:-5]
    P = {l.split()[0]: l.split() for l in open(f)}; L = {l.split()[0]: l.split() for l in open(o + '/' + d + '.law')}
    tot += len(P)
    for k in sorted(P):
        if P[k][-1] != L.get(k, [''])[-1]:
            mv += 1; lines.append('%s  %s -> %s  cmplines %s -> %s' % (k, P[k][4] if len(P[k]) > 4 else P[k][2], L[k][4] if len(L[k]) > 4 else L[k][2], P[k][3] if len(P[k]) > 3 else '', L[k][3] if len(L[k]) > 3 else ''))
open(o + '/movers.txt', 'w').write('cases %d byte movers %d\n' % (tot, mv) + '\n'.join(lines) + '\n')
print('cases', tot, 'movers', mv)
PY
