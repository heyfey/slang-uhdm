#!/bin/bash
source /tmp/v11u462_env.sh
B=/tmp/v11u462_bin/law.bin
cd /tmp/wt_v11u462/tools/probe/v11u462repro/cases
sw(){ case ${1%%/*} in VM) echo R11U462_CLSINMODTD_OFF;; VE) echo R11U462_CLSINMODENUM_OFF;; VA) echo R11U462_CLSMETHODAUTO_OFF;; VR) echo R11U462_CLSDYNREAL_OFF;; VB) echo R11U462_ENUMBASEINST_OFF;; VS) echo R11U462_UNITHOISTSYSF_OFF;; VC) echo R11U462_CLONERETVAR_OFF;; esac; }
for c in $(ls -d */*/ | sed 's|/$||'); do
  W=/tmp/v11u462_runs$(realpath $c)
  p=$(md5sum < $W/pris.uhdm | cut -c1-8); l=$(md5sum < $W/law.uhdm | cut -c1-8)
  (cd $c; rm -f $W/off.uhdm; env R11U462_OFF=1 $B dut.sv --single-unit --nobuiltin -o $W/off.uhdm >/dev/null 2>&1; echo $? > $W/off.rc)
  o=$(md5sum < $W/off.uhdm | cut -c1-8)
  S=$(sw $c); (cd $c; rm -f $W/own.uhdm; env $S=1 $B dut.sv --single-unit --nobuiltin -o $W/own.uhdm >/dev/null 2>&1)
  w=$(md5sum < $W/own.uhdm | cut -c1-8)
  echo "$c moved=$([ $p = $l ] && echo no || echo yes) ALL_OFF=$([ $o = $p ] && echo pristine || echo DIFF) offrc=$(cat $W/off.rc) $S=$([ $w = $p ] && echo pristine || ([ $w = $l ] && echo law || echo third))"
done
