#!/bin/bash
# ownsw.sh <casedir>... : run law with the case's own switch; compare to pristine bytes; then with NEWLHSKIND added
B=/tmp/v11u437_bin/law; [ -x $B ] || exit 2
declare -A SW=( [newLhsSelCgCopyAtIndex437]=R11U437_NEWLHSKIND_OFF [newLhsVarSelNameSpan437]=R11U437_NEWLHSVS_OFF [newLhsHpSelFirstSpan437]=R11U437_NEWLHSHP_OFF [foreachCgArrLoopVarRef437]=R11U437_FECGREF_OFF [dynArrNewElemLvalueBase437]=R11U437_DYNNEWELEM_OFF )
for d in "$@"; do
  law=$(head -1 $d/dut.sv | sed 's#// § ##' | tr -d ' \r'); s=${SW[$law]}
  rm -f $d/out_own.uhdm; (cd $d && env $s=1 $B dut.sv --single-unit --nobuiltin -o out_own.uhdm >/dev/null 2>&1 </dev/null); rc=$?
  if cmp -s $d/out_own.uhdm $d/out_p.uhdm; then r=OWN_RESTORES; else
    rm -f $d/out_own2.uhdm; (cd $d && env $s=1 R11U437_NEWLHSKIND_OFF=1 $B dut.sv --single-unit --nobuiltin -o out_own2.uhdm >/dev/null 2>&1 </dev/null)
    if cmp -s $d/out_own2.uhdm $d/out_p.uhdm; then r=OWN+KIND_RESTORES; else r=NOT_RESTORED; fi
  fi
  echo "$d $s rc=$rc $r"
done
