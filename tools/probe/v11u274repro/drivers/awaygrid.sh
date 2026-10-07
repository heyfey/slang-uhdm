#!/bin/bash
# v11u274 awaygrid.sh <grid.txt> <pristine bin> <law bin> (adapted from r11u274repro/drivers/awaygrid.sh): the
# chain-keyed away census (tools/probe/r11u272repro/drivers/awaychain.py) on every mover of a grid.  Case dirs
# resolve under the repo's tools/probe (V11U274_CASEROOT overrides the v11u274repro root while the cases live
# in scratch).  Needs $FENCED (fail-closed), $SCX, $S.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "awaygrid.sh: FENCED unset" >&2; exit 2; }
[ -x "$SCX" ] && [ -n "$S" ] || { echo "awaygrid.sh: SCX/S unset" >&2; exit 2; }
G=$1; P=$2; L=$3; HERE=$(cd "$(dirname "$0")" && pwd); REPO=${V11U274_REPO:-$(cd "$HERE/../../../.." && pwd)}
AW=$REPO/tools/probe/r11u272repro/drivers/awaychain.py
T=$S/awaygrid.$$; mkdir -p $T
{ if grep -q "^MOVER" $G; then cat $G; else python3 $HERE/gridsum.py $G; fi; } | grep '^MOVER' | while read -r _ c v _; do
  v=${v%:}; d=$REPO/tools/probe/$c
  case $c in v11u274repro/*) [ -n "$V11U274_CASEROOT" ] && d=$V11U274_CASEROOT/${c#v11u274repro/};; esac
  rm -f $T/p.uhdm $T/l.uhdm
  KEEP=$T/p.uhdm $HERE/case.sh $d $P $v > /dev/null; KEEP=$T/l.uhdm $HERE/case.sh $d $L $v > /dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  g=${R274_GOLD:-/tmp/v11u274_gold}/$h/g.uhdm
  echo "$c $v $(python3 $AW $g $T/p.uhdm $T/l.uhdm | head -1)"
done
rm -rf $T
