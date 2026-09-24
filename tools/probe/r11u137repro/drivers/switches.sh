#!/bin/bash
# switches.sh <grid root> [elab] -> per case: law vs pristine bytes; R11U137_OFF=1 -> pristine?; which single switch moves it back
source /tmp/r11u137_env.sh
B=${LAWBIN:-/tmp/r11u137_bin/l18}; PB=/tmp/r11u137_bin/pris
EX=""; [ "$2" = elab ] && EX="--elabuhdm"
SW="R11U137_PATD_OFF R11U137_EMPTYCONN_OFF R11U137_UNSIGNEDSPAN_OFF R11U137_CALLSPAN_OFF R11U137_REPLTSNAME_OFF R11U137_ELABCLONE_OFF R11U137_PUREVIRTSPAN_OFF R11U137_TAGGEDSPAN_OFF R11U137_DEFNETTP_OFF R11U137_ALIASFILE_OFF R11U137_SCOPEDARRTD_OFF R11U137_PATHBASE_OFF R11U139_CA_OFF R11U139_NDA_OFF R11U139_CLK_OFF R11U139_PORT_OFF"
for d in $(find $1 -name dut.sv | xargs -n1 dirname | sort); do
  d=$(realpath $d); w=/tmp/r11u137_scr/sw/$(echo "$d$EX" | md5sum | cut -c1-12); mkdir -p $w
  (cd $d && rm -f $w/*.uhdm && $PB dut.sv --single-unit --nobuiltin $EX -o $w/P.uhdm >/dev/null 2>&1; $B dut.sv --single-unit --nobuiltin $EX -o $w/L.uhdm >/dev/null 2>&1; R11U137_OFF=1 $B dut.sv --single-unit --nobuiltin $EX -o $w/O.uhdm >/dev/null 2>&1)
  n=$(basename $(dirname $d))/$(basename $d)
  [ -f $w/P.uhdm ] || { echo "$n	nodb"; continue; }
  moved=$(cmp -s $w/P.uhdm $w/L.uhdm && echo same || echo moved)
  off=$(cmp -s $w/P.uhdm $w/O.uhdm && echo pristine || echo DIFFERS)
  laws=""
  if [ $moved = moved ]; then
    for s in $SW; do (cd $d && rm -f $w/s.uhdm && env $s=1 $B dut.sv --single-unit --nobuiltin $EX -o $w/s.uhdm >/dev/null 2>&1); cmp -s $w/s.uhdm $w/L.uhdm || laws="$laws ${s#R11U13?_}"; done
  fi
  echo "$n	$moved	off=$off	laws:${laws:- -}"
done
