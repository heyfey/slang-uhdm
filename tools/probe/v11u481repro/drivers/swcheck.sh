#!/bin/bash
# swcheck.sh <envassign> <reftag> dirs... : run ver2 with env, compare md5 to <reftag>.uhdm in the run dir
E=$1; R=$2; shift 2
B=/tmp/v11u481_bin/ver2; [ -x "$B" ] || exit 1
eq=0; ne=0
for c in "$@"; do c=$(realpath $c); W=/tmp/v11u481_runs$c; o=/tmp/v11u481_swc.uhdm; rm -f $o
  (cd $c && env $E "$B" dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null)
  if [ -f "$W/$R.uhdm" ] && cmp -s $o "$W/$R.uhdm"; then eq=$((eq+1)); else ne=$((ne+1)); echo "  differs ${c#*/cases/}"; fi
done
echo "$E vs $R: equal $eq differ $ne"
