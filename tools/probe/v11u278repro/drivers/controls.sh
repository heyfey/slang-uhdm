#!/bin/bash
# (v11u278: copied from r11u278repro/drivers)
# r11u278 controls.sh <out.txt> <pristine bin> <law bin> <repro dir>...: byte controls.  Every case dir
# (dut.sv / dut.v) under the named tools/probe repro dirs, in both views, on pristine and the law
# (drivers/case.sh lines, exit codes included), two in parallel.  The path list is built first and
# filtered by $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "controls.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; P=$2; L=$3; shift 3; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for v in d e; do echo "$c $v pristine $P"; echo "$c $v law $L"; done; done |
  xargs -P 2 -L 1 bash -c 'echo "$(echo $0 | sed "s#.*/tools/probe/##") $1 $2 $('"$H"'/drivers/case.sh $0 $3 $1)"' >> $out
