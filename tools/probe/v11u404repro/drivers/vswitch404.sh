#!/bin/bash
# vswitch404.sh <pristine> <law> <verified> <work> <caseroot> : per case, the verified binary with
# R11V404_OFF (vs law bytes), R11U404_OFF (vs pristine bytes) and the case's own refinement switch (vs law bytes).
P=$1; L=$2; V=$3; W=$4; CR=$5
declare -A SW=([ifacePrgOrderedConnMaterializes404v]=R11V404_IFPRGCONN_OFF [builtinClassElemNotInClass404v]=R11V404_BICLASSMETH_OFF [unitWideFillOnesBin404v]=R11V404_WIDEFILL_OFF)
for d in $(cd $CR && ls -d */*/ | sort); do
  d=${d%/}; c=$CR/$d; w=$W/$d; mkdir -p $w
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  run() { local o=$w/$1.uhdm; shift; rm -f "${o:?}"; (cd $w && env "$@" ${T:+--top $T} $c/dut.sv --single-unit -o $o > /dev/null 2>&1); echo $?; }
  rp=$(run p $P); rl=$(run l $L); rv=$(run v $V); rvo=$(run vo R11V404_OFF=1 $V); ruo=$(run uo R11U404_OFF=1 $V)
  law=$(head -1 $c/dut.sv | sed 's#^// § ##'); sw=${SW[$law]:-}
  own=""; if [ -n "$sw" ]; then rs=$(run s $sw=1 $V); own="| $sw rc=$rs $(cmp -s $w/l.uhdm $w/s.uhdm && echo =law || echo DIFF)"; fi
  echo "$d | rc p=$rp l=$rl v=$rv | ver-vs-law $(cmp -s $w/l.uhdm $w/v.uhdm && echo same || echo moved) | R11V404_OFF rc=$rvo $(cmp -s $w/l.uhdm $w/vo.uhdm && echo =law || echo DIFF) | R11U404_OFF rc=$ruo $(cmp -s $w/p.uhdm $w/uo.uhdm && echo =pris || echo DIFF) $own"
done
