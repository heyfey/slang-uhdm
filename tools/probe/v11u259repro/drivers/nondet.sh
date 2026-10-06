#!/bin/bash
# (v11u259: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# r11u259 nondet.sh <n> <binary> <ENV=VAL> <case dir>...: n CONCURRENT draws per case and view of the binary under
# the environment; prints the hash histogram per case-view. Fail-closed on $FENCED.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
n=$1; bin=$2; ev=$3; shift 3
[ -x "$bin" ] || { echo "nondet.sh: binary not executable" >&2; exit 2; }
for c in "$@"; do
  echo "$c" | grep -qwE "$FENCE_RE" && { echo "$c FENCED-REFUSED"; continue; }
  for v in "" --elabuhdm; do
    t=$S/nd_$$; rm -rf $t; mkdir -p $t
    for i in $(seq $n); do (cd $c && env $ev $bin dut.sv --single-unit --nobuiltin $v -o $t/$i.uhdm >/dev/null 2>&1; echo $? > $t/$i.rc) & done; wait
    h=$(for i in $(seq $n); do echo "$(md5sum < $t/$i.uhdm | cut -c1-8)/rc$(cat $t/$i.rc)"; done | sort | uniq -c | tr '\n' ' ')
    echo "$(basename $c) ${v:-def} $(basename $bin) $ev: $h"
    rm -rf $t
  done
done
