#!/bin/bash
# v11u274 vcontrols.sh <out.txt> <pristine bin> <law bin> <fix bin> <repro dir>...: byte controls on three binaries.
# Every case dir (dut.sv / dut.v) under the named tools/probe repro dirs, in both views (drivers/case.sh lines, exit
# codes included), two in parallel.  The path list is built first and filtered by $FENCED (word boundary) before
# any case is opened.  Repro dirs resolve under $V11U274_REPO/tools/probe (default: this repo).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "vcontrols.sh: FENCED unset" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); REPO=${V11U274_REPO:-$(cd "$HERE/../../../.." && pwd)}
out=$1; P=$2; L=$3; X=$4; shift 4; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $REPO/tools/probe/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for v in d e; do echo "$c $v pristine $P"; echo "$c $v law $L"; echo "$c $v fix $X"; done; done |
  xargs -P 2 -L 1 bash -c 'echo "$(echo $0 | sed "s#.*/tools/probe/##") $1 $2 $('"$HERE"'/case.sh $0 $3 $1)"' >> $out
