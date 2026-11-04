#!/bin/bash
# bytecensus.sh <list> <out> <tag:bin>...: our exit code and md5 per case dir and binary (explicit dirs)
L=$1; O=$2; shift 2
one() {
  c=$1; shift
  h=$(echo "$c" | md5sum | cut -c1-12); W=/tmp/v11u482_bc/$h; mkdir -p $W
  line="$c"
  for tb in "$@"; do t=${tb%%:*}; b=${tb#*:}
    rm -f $W/$t.uhdm; (cd "$c" && timeout 120 "$b" dut.sv --single-unit --nobuiltin -o $W/$t.uhdm >/dev/null 2>&1 </dev/null); rc=$?
    m=$( [ -f $W/$t.uhdm ] && md5sum < $W/$t.uhdm | cut -c1-12 || echo none)
    line="$line $t:$rc:$m"
  done
  echo "$line"
}
export -f one
xargs -P ${CJOBS:-3} -I{} bash -c 'one "$@"' _ {} "$@" < $L > $O
