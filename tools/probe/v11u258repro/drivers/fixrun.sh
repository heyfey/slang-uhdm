#!/bin/bash
# v11u258 fixrun.sh <out> <tag> <binary> <dir>...: every case under the given tools/probe repro dirs (or case dirs) in both
# views through r11u258repro/drivers/case.sh with one binary, two in parallel; one case.sh line per case-view (exit code
# included). Paths are listed first and filtered by $FENCED (word boundary) before any case is opened; fail-closed.
[ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$B" ] || { echo "fixrun.sh: source r11u258repro/drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/../.." && pwd); out=$1; tag=$2; bin=$3; shift 3; : > $out
[ -x "$bin" ] || { echo "fixrun.sh: binary not executable" >&2; exit 2; }
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $(realpath $d) \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c $tag $bin"; done; done |
  xargs -P 2 -L 1 bash -c 'EL=$0 '"$H"'/r11u258repro/drivers/case.sh $1 $2 $3' >> $out
