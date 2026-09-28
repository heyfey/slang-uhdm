#!/bin/bash
# switches.sh: every case-view the law binary moves, re-run under each r11u214 switch alone; prints which switches
# restore the pristine bytes (the switch reach). Needs env.sh; LAWBIN/PRISBIN as grid.sh.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAWBIN=${LAWBIN:-law.p}; PRISBIN=${PRISBIN:-pristine.p}
SW="R11U214_SEQARBNAME_OFF R11U214_ENUMPKGW_OFF R11U214_ENUMCLSW_OFF R11U214_ENUMALIASGRP_OFF R11U214_ENUMALIASNAME_OFF R11U214_CLASSTDW_OFF R11U214_CLSSCOPETD_OFF R11U214_QUALSPAN_OFF R11U214_VALENC_OFF R11U214_CLONENAME_OFF R11U214_IMPVARELEM_OFF R11U214_UNITCOPYTS_OFF"
one() { c=$1; el=$2
  pm=$(EL=$el bash $HERE/case.sh $c P $B/$PRISBIN 2>/dev/null | grep -o 'md5=[0-9a-f]*'); lm=$(EL=$el bash $HERE/case.sh $c L $B/$LAWBIN 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  [ "$pm" = "$lm" ] && return; out=""
  for s in $SW; do m=$(EL=$el bash $HERE/case.sh $c S $B/$LAWBIN $s=1 2>/dev/null | grep -o 'md5=[0-9a-f]*'); [ "$m" = "$pm" ] && out="$out $s"; done
  echo "$(echo $c | sed 's#.*/cases/##')$([ $el = 1 ] && echo _el) restored_by:${out:- NONE}"; }
export -f one; export HERE LAWBIN PRISBIN SW
find $HERE/../cases \( -name dut.sv -o -name args \) -printf '%h\n' | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P2 -L1 bash -c 'one $0 $1' | sort
