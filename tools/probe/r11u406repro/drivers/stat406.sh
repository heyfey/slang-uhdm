#!/bin/bash
# stat406.sh <binary> <work dir> [case-glob]  : per case rc, uhdm-cmp rc, strict verdict, dump-diff lines vs Surelog's golden
source /tmp/r11u406_env.sh
B=$1; W=$2; G=${3:-*/*}
HERE=$(cd "$(dirname "$0")/.." && pwd); SC=/tmp/wt_r11u406/build/uhdm-strictcmp
for d in $(cd $HERE/cases && ls -d $G/ | sort); do
  d=${d%/}; c=$HERE/cases/$d; w=$W/$d; mkdir -p $w
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  [ -f $w/g/slpp_all/surelog.uhdm ] || (cd $w && $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g $c/dut.sv > sl.log 2>&1)
  rm -f $w/l.uhdm; (cd $w && $B ${T:+--top $T} $c/dut.sv --single-unit -o $w/l.uhdm > l.log 2>&1); r=$?
  if [ -f $w/l.uhdm ]; then
    $UHDM_CMP $w/g/slpp_all/surelog.uhdm $w/l.uhdm >/dev/null 2>&1; cr=$?
    sv=$($SC $w/g/slpp_all/surelog.uhdm $w/l.uhdm 2>&1 | tail -1 | awk '{print $1,$2}')
    $UHDM_DUMP $w/g/slpp_all/surelog.uhdm 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > $w/g.dump
    $UHDM_DUMP $w/l.uhdm 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > $w/l.dump
    n=$(diff $w/g.dump $w/l.dump | grep -c '^[<>]')
  else cr=-; sv=nodb; n=-; fi
  echo "$d rc=$r cmp=$cr $sv dumpdiff=$n"
done
