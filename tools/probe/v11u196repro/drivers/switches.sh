#!/bin/bash
# switches.sh: for each r11u196 / r11u191 / v11u196 switch alone, the fresh cases whose fix-binary database moves (both views)
. "$(dirname "$0")/env.sh"
C=$(find $V196_REPO/tools/probe/v11u196repro/cases -name dut.sv | sed 's#/dut.sv##' | sort)
run() { (cd $1 && env $2 $V196_BIN/fix dut.sv --single-unit --nobuiltin $3 -o /tmp/v11u196_sw_$$.uhdm >/dev/null 2>&1); md5sum < /tmp/v11u196_sw_$$.uhdm 2>/dev/null | cut -c1-12; rm -f /tmp/v11u196_sw_$$.uhdm; }
declare -A base
for d in $C; do for v in "" --elabuhdm; do base[$d$v]=$(run $d X_NONE=1 "$v"); done; done
for s in R11U196_MODGENERIC_OFF R11U196_MODGENHANDLE_OFF R11U196_MODCLSLINK_OFF R11U196_ELEMCLSNAME_OFF R11U196_RETQUALTD_OFF R11U196_TPARRBOUND_OFF R11U196_DFLTARG_OFF R11U196_FORMALCLONEFILE_OFF R11U191_REFFULL_OFF R11U191_QUEUERANGE_OFF R11U191_CONSTCALL_OFF R11U191_UNSIZEDPKG_OFF R11U191_ENUMPARENT_OFF R11U191_HDRTD_OFF R11U191_REALPORT_OFF R11V196_DFLTEXEC_OFF R11V196_DFLTEVAL_OFF; do
  mv=""; for d in $C; do for v in "" --elabuhdm; do h=$(run $d $s=1 "$v"); [ "$h" = "${base[$d$v]}" ] || mv="$mv ${d#$V196_REPO/tools/probe/v11u196repro/cases/}${v:+(el)}"; done; done
  echo "$s:$mv"
done
