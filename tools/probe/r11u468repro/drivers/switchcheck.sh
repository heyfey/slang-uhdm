#!/bin/bash
# switchcheck.sh <pristine> <law> <casedir>...: per case dir, the exit codes and whether the law
# binary under R11U468_OFF=1 and under each law's own switch gives pristine's bytes; the firing
# laws come from R11U468_TRACE.  A FILES file lists the sources; a dut.sv importing uvm_pkg gets
# the bundled UVM sources (the sv-tests recipe).
A=$1; B=$2; shift 2
[ -x "$A" ] && [ -x "$B" ] || { echo "missing binary"; exit 1; }
U=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0/src
SW="UNITINCLCLS SPECIMPFORMAL PROPSPECFULL OOBIMPCLS SPECARGTD"
for c in "$@"; do
  [ -d "$c" ] || continue
  c=$(realpath "$c")
  W=/tmp/r11u468_sc$c; mkdir -p $W/tr; rm -f $W/*.uhdm $W/tr/*
  F="dut.sv --nobuiltin"; [ -f $c/FILES ] && F="$(cat $c/FILES) --nobuiltin"
  grep -q 'uvm_pkg' $c/dut.sv && F="-I$U $U/uvm_pkg.sv dut.sv"
  (cd $c && "$A" $F --single-unit -o $W/p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $c && R11U468_TRACE=$W/tr "$B" $F --single-unit -o $W/l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  (cd $c && R11U468_OFF=1 "$B" $F --single-unit -o $W/o.uhdm >/dev/null 2>&1 </dev/null); ro=$?
  fires=$(cat $W/tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u | tr '\n' ',')
  moved=same; cmp -s $W/p.uhdm $W/l.uhdm || moved=MOVED
  off=$(cmp -s $W/p.uhdm $W/o.uhdm && [ $rp = $ro ] && echo off=pristine || echo off=DIFF)
  own=""
  if [ $moved = MOVED ]; then
    for s in $SW; do
      rm -f $W/s.uhdm
      (cd $c && env R11U468_${s}_OFF=1 "$B" $F --single-unit -o $W/s.uhdm >/dev/null 2>&1 </dev/null)
      cmp -s $W/p.uhdm $W/s.uhdm && own="$own $s"
    done
  fi
  echo "${c#*/cases/} rc $rp/$rl $moved $off fires=$fires restored-by:${own:- none-alone}"
done
