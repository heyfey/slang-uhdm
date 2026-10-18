#!/bin/bash
# usage: r11u404_case.sh <dir> [binary] [top]  : golden (cached in dir/g) vs binary; dump diff
source /tmp/r11u404_env.sh
cd $1; B=${2:-/tmp/wt_r11u404/build/slang-uhdm}; T=${3:-}
[ -f g/slpp_all/surelog.uhdm ] || $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g dut.sv > sl.log 2>&1
rm -f l.uhdm; $B ${T:+--top $T} dut.sv --single-unit -o l.uhdm > l.log 2>&1; echo "rc=$?"; head -3 l.log
$UHDM_DUMP g/slpp_all/surelog.uhdm 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > g.dump
$UHDM_DUMP l.uhdm 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > l.dump
echo "cmp: $($UHDM_CMP g/slpp_all/surelog.uhdm l.uhdm >/dev/null 2>&1; echo $?) strict: $(/tmp/wt_r11u404/build/uhdm-strictcmp g/slpp_all/surelog.uhdm l.uhdm 2>&1 | tail -1)"
diff g.dump l.dump | head -${N:-60}
