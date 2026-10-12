#!/bin/bash
# v11u288 awaygrid.sh <grid.txt> <tagA> <binA> <tagB> <binB>: the chain-keyed away census (awaychain.py, $SCX
# records with the raw full name) on every case-view whose md5 differs between tagA and tagB in the grid file.
# Fail-closed on $FENCED; $SCX must be executable.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "awaygrid.sh: FENCED unset" >&2; exit 2; }
[ -x "$SCX" ] || { echo "awaygrid.sh: SCX unset" >&2; exit 2; }
G=$1; TA=$2; A=$3; TB=$4; B=$5; H=$(cd "$(dirname "$0")" && pwd); CB=${CB:-$H/../cases}
T=/tmp/v11u288_aw.$$; mkdir -p $T
python3 - "$G" "$TA" "$TB" <<'PY' | while read -r c v; do
import sys, collections
g, ta, tb = sys.argv[1:4]; r = collections.defaultdict(dict)
for l in open(g):
    w = l.split(); r[(w[0], w[1])][w[2]] = l.split('md5=')[-1].strip() if 'md5=' in l else l
for k in sorted(r):
    if ta in r[k] and tb in r[k] and r[k][ta] != r[k][tb]: print(*k)
PY
  d=$CB/$c; rm -f $T/a.uhdm $T/b.uhdm
  KEEP=$T/a.uhdm bash $H/case.sh $d $A $v > /dev/null; KEEP=$T/b.uhdm bash $H/case.sh $d $B $v > /dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  echo "$c $v $(python3 $H/awaychain.py ${V288_GOLD:-/tmp/v11u288_gold}/$h/g.uhdm $T/a.uhdm $T/b.uhdm | head -1)"
done
rm -rf $T
