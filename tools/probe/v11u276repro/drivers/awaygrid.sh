#!/bin/bash
# (v11u276: copied from r11u276repro/drivers, own golden dir)
# r11u276 awaygrid.sh <grid.txt | controls summary> <pristine bin> <law bin>: the chain-keyed away census
# (tools/probe/r11u272repro/drivers/awaychain.py, records of $SCX = strictcmp_x with the raw
# full name) on every mover (gridsum.py's MOVER lines of a grid, or the MOVER lines of a ctlsum.py
# summary): golden, pristine and law databases of the case-view.
# One line per mover.  Needs $FENCED (fail-closed), $SCX, $S (record cache).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "awaygrid.sh: FENCED unset" >&2; exit 2; }
[ -x "$SCX" ] && [ -n "$S" ] || { echo "awaygrid.sh: SCX/S unset" >&2; exit 2; }
G=$1; P=$2; L=$3; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
AW=$REPO/tools/probe/r11u272repro/drivers/awaychain.py
T=$S/awaygrid; mkdir -p $T
{ if grep -q '^MOVER' $G; then cat $G; else python3 $HERE/gridsum.py $G; fi; } | grep '^MOVER' | while read -r _ c v _; do
  v=${v%:}; d=$REPO/tools/probe/$c
  rm -f $T/p.uhdm $T/l.uhdm
  KEEP=$T/p.uhdm $HERE/case.sh $d $P $v > /dev/null; KEEP=$T/l.uhdm $HERE/case.sh $d $L $v > /dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  g=${V276_GOLD:-/tmp/v11u276_gold}/$h/g.uhdm
  echo "$c $v $(python3 $AW $g $T/p.uhdm $T/l.uhdm | head -1)"
done
