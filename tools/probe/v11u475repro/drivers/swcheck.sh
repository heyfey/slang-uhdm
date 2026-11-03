#!/bin/bash
# swcheck.sh <bin> <ENV=1> <casedir>... : runs <bin> under the switch and compares with the
# pristine run's database (pris.uhdm from runcase.sh) and the law run's (law.uhdm); prints SAME_PRIS/SAME_LAW/OTHER
B=$1; SW=$2; shift 2
[ -x "$B" ] || exit 1
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u475_runs$c
  rm -f $W/sw.uhdm; (cd $c && env $SW "$B" dut.sv --single-unit --nobuiltin -o $W/sw.uhdm >/dev/null 2>&1); rc=$?
  m=$(md5sum < $W/sw.uhdm); p=$(md5sum < $W/pris.uhdm); l=$(md5sum < $W/law.uhdm)
  r=OTHER; [ "$m" = "$l" ] && r=SAME_LAW; [ "$m" = "$p" ] && r=SAME_PRIS
  echo "${c#*/cases/} $SW rc=$rc $r"
done
