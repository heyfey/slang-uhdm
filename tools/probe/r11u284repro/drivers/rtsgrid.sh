#!/bin/bash
# r11u284 rtsgrid.sh <binary> <view d|e> <case dir>...: per case-view the case.sh line, then rtsinfo (ALIASONLY=1 by
# default; RTSRE=<regex> lists every matching ref_typespec instead) on the golden (G) and on ours (O).
# Fail-closed on $FENCED (case.sh and rtsinfo refuse fenced paths).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rtsgrid: FENCED unset" >&2; exit 2; }
H=$(dirname "$(realpath "$0")"); RT=${RTSINFO:-/tmp/r11u284_bin/rtsinfo}; [ -x "$RT" ] || exit 2
bin=$1; v=$2; shift 2
for d in "$@"; do
  d=$(realpath $d); k=/tmp/r11u284_scratch/rtsgrid.$$.uhdm; rm -f $k
  echo "== $d $v $(KEEP=$k bash $H/case.sh $d $bin $v 5)"
  h=$( (cd $d && command find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  g=${R284_GOLD:-/tmp/r11u284_gold}/$h/g.uhdm
  if [ -n "$RTSRE" ]; then
    [ -s $g ] && "$RT" $g "$RTSRE" | sed 's/^/  G /'; [ -s $k ] && "$RT" $k "$RTSRE" | sed 's/^/  O /'
  else
    [ -s $g ] && env ${RTSMODE:-ALIASONLY}=1 "$RT" $g x | sed "s/^/  G /"; [ -s $k ] && env ${RTSMODE:-ALIASONLY}=1 "$RT" $k x | sed "s/^/  O /"
  fi
  rm -f $k
done
