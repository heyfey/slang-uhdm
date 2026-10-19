#!/bin/bash
# usage: r11u406_case.sh <case dir> <work dir> [binary]  : golden (cached in work/g) vs binary; strict verdict + dump diff
source /tmp/r11u406_env.sh
C=$(cd $1 && pwd); W=$2; B=${3:-$SLANG_UHDM}; mkdir -p $W; cd $W
T=""; grep -q '^module top\b' $C/dut.sv && T=top
[ -f g/slpp_all/surelog.uhdm ] || $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g $C/dut.sv > sl.log 2>&1
rm -f l.uhdm; $B ${T:+--top $T} $C/dut.sv --single-unit -o $W/l.uhdm > l.log 2>&1; echo "rc=$?"; head -3 l.log
[ -x "$UHDM_DUMP" ] || exit 1
$UHDM_DUMP g/slpp_all/surelog.uhdm 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > g.dump
[ -f l.uhdm ] && $UHDM_DUMP l.uhdm 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > l.dump
echo "cmp: $($UHDM_CMP g/slpp_all/surelog.uhdm l.uhdm >/dev/null 2>&1; echo $?) strict: $(/tmp/wt_r11u406/build/uhdm-strictcmp g/slpp_all/surelog.uhdm l.uhdm 2>&1 | tail -1)"
diff g.dump l.dump | head -${N:-60}
