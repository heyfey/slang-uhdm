#!/bin/bash
# r11u284 corpcensus.sh <sweep workdir> <out> [rtsinfo mode env, e.g. ALIASONLY=1]: rtsinfo over every corpus
# row-mode's golden and slang database of one sweep workdir.  The cmds.txt path list is built first and filtered by
# $FENCED (word boundary, fail-closed) before any file is opened.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "corpcensus: FENCED unset" >&2; exit 2; }
RT=${RTSINFO:-/tmp/r11u284_bin/rtsinfo}; [ -x "$RT" ] || { echo "corpcensus: rtsinfo missing" >&2; exit 2; }
wd=$1; out=$2; : > $out
command find $wd/surelog $wd/uhdm2rtlil -mindepth 3 -maxdepth 3 -name cmds.txt | grep -vwE "$(echo $FENCED | tr ' ' '|')" | sort > $out.list
while read -r c; do
  d=$(dirname $c); row=${d#$wd/}
  [ -s $d/slang.uhdm ] || continue
  g=$(grep -o 'golden cache hit [^)]*' $c | awk '{print $4}')
  [ -n "$g" ] && [ -d "$g" ] || continue
  gf=$g/golden.uhdm; [ -s "$gf" ] || continue
  "$RT" $gf x 2>/dev/null | sed "s#^#$row\tG\t#" >> $out
  "$RT" $d/slang.uhdm x 2>/dev/null | sed "s#^#$row\tO\t#" >> $out
done < $out.list
