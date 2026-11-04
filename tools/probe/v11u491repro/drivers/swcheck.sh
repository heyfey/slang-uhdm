#!/bin/bash
# swcheck.sh <bin> <envassign|none> <reftag> <casedir>... : prints case and SAME/DIFF vs runs/<case>/<reftag>.uhdm (and rc)
B=$1; E=$2; R=$3; shift 3
[ -x "$B" ] || exit 1
for c in "$@"; do c=$(realpath "$c"); W=/tmp/v11u491_runs$c; O=/tmp/v11u491_sw$c; mkdir -p $O; rm -f $O/o.uhdm
  if [ "$E" = none ]; then (cd $c && "$B" dut.sv --single-unit --nobuiltin -o $O/o.uhdm >/dev/null 2>&1 </dev/null); else (cd $c && env $E "$B" dut.sv --single-unit --nobuiltin -o $O/o.uhdm >/dev/null 2>&1 </dev/null); fi; rc=$?
  a=$(md5sum < $O/o.uhdm | cut -c1-32); b=$(md5sum < $W/$R.uhdm | cut -c1-32)
  [ "$a" = "$b" ] && s=SAME || s=DIFF; echo "${c#*/cases/} $s rc=$rc"
done
