#!/usr/bin/env bash
# r11u52 arm scorer.  Per arm, compares the CELL tables (cell52.py --all) of
# golden-vs-base and golden-vs-law and reports, by source position:
#   TOWARD  a cell that disagreed at base and agrees after the law
#   AWAY    a cell that AGREED at base and disagrees after  (must be 0)
#   STILL   a cell that disagreed in both (a residue)
# usage: score52.sh [arms...]
set -u
GRID=${GRID:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/grid}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BASE=${BASE:-base}
LAW=${LAW:-law2}
ARMS=${*:-$(ls -d $GRID/* | xargs -n1 basename | sort -V)}
tot_t=0; tot_a=0; tot_s=0
for a in $ARMS; do
  d=$GRID/$a
  [ -f $d/gold.$BASE.dump ] && [ -f $d/ours.$BASE.dump ] || continue
  [ -f $d/gold.$LAW.dump ] && [ -f $d/ours.$LAW.dump ] || continue
  python3 $HERE/cell52.py --all $d/gold.$BASE.dump $d/ours.$BASE.dump > /tmp/.r11u52_b.$$
  python3 $HERE/cell52.py --all $d/gold.$LAW.dump  $d/ours.$LAW.dump  > /tmp/.r11u52_l.$$
  read t w s < <(python3 - /tmp/.r11u52_b.$$ /tmp/.r11u52_l.$$ <<'PY'
import sys
def load(p):
    out = {}
    for line in open(p):
        k, rest = line.split('|', 1)
        cols = rest.split('||')
        out[k.strip()] = (cols[0].strip(), cols[1].strip() if len(cols) > 1 else '')
    return out
b, l = load(sys.argv[1]), load(sys.argv[2])
t = w = s = 0
for k in set(b) | set(l):
    eb = b.get(k, ('', ''))
    el = l.get(k, ('', ''))
    okb, okl = eb[0] == eb[1], el[0] == el[1]
    if not okb and okl:
        t += 1
    elif okb and not okl:
        w += 1
        print('AWAY %s base(%s||%s) law(%s||%s)' % (k, eb[0], eb[1], el[0], el[1]),
              file=sys.stderr)
    elif not okb and not okl:
        s += 1
print(t, w, s)
PY
)
  echo "$a TOWARD=$t AWAY=$w STILL=$s"
  tot_t=$((tot_t+t)); tot_a=$((tot_a+w)); tot_s=$((tot_s+s))
  rm -f /tmp/.r11u52_b.$$ /tmp/.r11u52_l.$$
done
echo "TOTAL TOWARD=$tot_t AWAY=$tot_a STILL=$tot_s"
[ $tot_a -eq 0 ] && echo PASS || echo FAIL
