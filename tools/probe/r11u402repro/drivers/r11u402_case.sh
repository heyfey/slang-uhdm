#!/bin/bash
# usage: r11u402_case.sh <casedir> [binary...]  : golden via surelog (cached per text md5), ours per binary; prints cmp/strict verdict
. /tmp/r11u402_env.sh
c=$(readlink -f $1); shift
h=$(cat $c/*.sv | md5sum | cut -c1-12); G=/tmp/r11u402_gold/$h
if [ ! -f $G/slpp_all/surelog.uhdm ]; then rm -rf $G; mkdir -p $G; cp $c/*.sv $G/; (cd $G && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 > surelog.log 2>&1); fi
for b in "$@"; do
  w=/tmp/r11u402_cw/$(basename $b)/$h; rm -rf $w; mkdir -p $w; cp $c/*.sv $w/
  (cd $w && timeout 300 $b dut.sv --single-unit --nobuiltin -o $w/out.uhdm > slang.log 2>&1; echo $? > rc)
  v=$( $UHDM_CMP $G/slpp_all/surelog.uhdm $w/out.uhdm >/dev/null 2>&1 && /tmp/wt_r11u402/build/uhdm-strictcmp $G/slpp_all/surelog.uhdm $w/out.uhdm 2>&1 | tail -1 || echo CMP_NOTEQUAL)
  echo "$(basename $c) $(basename $b) rc=$(cat $w/rc) $v"
done
