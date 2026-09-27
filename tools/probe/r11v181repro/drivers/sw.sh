#!/bin/bash
# sw.sh <caserel> : switch matrix of ver2 on one case-mode
source $(dirname "${BASH_SOURCE[0]}")/env.sh
rel=$1; w=/tmp/v11u181_g/$rel; c=${rel%.elab}; case $c in tp/*) c=/tmp/wt_v11u181/tools/probe/${c#tp/};; *) c=/tmp/v11u181_cases/$c;; esac; el=""; [[ $rel == *.elab ]] && el=1
out=""
for sw in NONE R11V181_NESTRD_OFF R11V181_RDCALL_OFF R11V181_LVCALLPS_OFF R11V181_DECBIG_OFF R11V181_OFF R11U181_OFF; do
  o=/tmp/v11u181_swm.uhdm; rm -f $o
  (cd $c && env $sw=1 /tmp/v11u181_bin/ver2.bin ${el:+--elabuhdm} dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1)
  d=$($UHDM_DUMP $o 2>/dev/null | tail -n +2 | md5sum | cut -c1-8)
  l=$(tail -n +2 $w/L.dump | sed "s#W/#$w/#g" | md5sum | cut -c1-8)
  p=$(tail -n +2 $w/P.dump | sed "s#W/#$w/#g" | md5sum | cut -c1-8)
  v=$(tail -n +2 $w/V.dump | sed "s#W/#$w/#g" | md5sum | cut -c1-8)
  r=other; [ $d = $v ] && r=V; [ $d = $l ] && r=L; [ $d = $p ] && r=P; [ $l = $p ] && [ $d = $l ] && r=L=P
  out="$out ${sw/R11V181_/}:$r"
done
echo "$rel$out"
