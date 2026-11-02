#!/bin/bash
# switchcheck.sh <lawbin> <pristinebin> <casedir>...: md5 of ours under each switch against pristine
source ${ENVFILE:-/tmp/r11u462_env.sh} || exit 1
L=$1; P=$2; shift 2
SW="R11U462_OFF R11U462_CLSINMODTD_OFF R11U462_CLSINMODENUM_OFF R11U462_CLONERETVAR_OFF R11U462_ENUMBASEINST_OFF R11U462_UNITHOISTSYSF_OFF R11U462_CLSMETHODAUTO_OFF R11U462_CLSDYNREAL_OFF"
for c in "$@"; do
  [ -d "$c" ] || continue
  c=$(realpath "$c"); n=${c#*/r11u462repro/cases/}; T=/tmp/r11u462_sw$c; mkdir -p $T
  rm -f $T/p.uhdm $T/l.uhdm; (cd $c && $P dut.sv --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1 </dev/null); prc=$?
  (cd $c && $L dut.sv --single-unit --nobuiltin -o $T/l.uhdm >/dev/null 2>&1 </dev/null); lrc=$?
  pm=$(md5sum < $T/p.uhdm 2>/dev/null | cut -c1-8); lm=$(md5sum < $T/l.uhdm 2>/dev/null | cut -c1-8)
  line="$n pris=$pm/$prc law=$lm/$lrc"
  for s in $SW; do rm -f $T/s.uhdm; (cd $c && env $s=1 $L dut.sv --single-unit --nobuiltin -o $T/s.uhdm >/dev/null 2>&1 </dev/null); src=$?; sm=$(md5sum < $T/s.uhdm 2>/dev/null | cut -c1-8); tag=law; [ "$sm" = "$pm" ] && tag=PRIS; [ "$sm" != "$pm" ] && [ "$sm" != "$lm" ] && tag=OTHER; line="$line ${s#R11U462_}=$tag/$src"; done
  echo "$line"
done
