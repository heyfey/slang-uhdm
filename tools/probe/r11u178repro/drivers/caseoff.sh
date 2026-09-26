#!/bin/bash
# caseoff.sh <binary> <pristine binary> [ENV=VAL ...]: every case of this directory (cases/*/*/dut.sv), both
# modes (default; --elabuhdm), exported by <binary> under the environment and by the pristine binary; prints the
# byte verdict per case-mode and a tally.  Cases only (no corpus source is read).
set -u; B=$1; P=$2; shift 2; R=/tmp/wt_r11u178/tools/probe/r11u178repro; T=/tmp/r11u178_coff.$$; mkdir -p $T; s=0; d=0
for c in $R/cases/*/*/; do for e in "" "--elabuhdm"; do
  rm -f $T/a.uhdm $T/b.uhdm
  (cd $c && env "$@" $B $e dut.sv --single-unit --nobuiltin -o $T/a.uhdm >/dev/null 2>&1 </dev/null)
  (cd $c && $P $e dut.sv --single-unit --nobuiltin -o $T/b.uhdm >/dev/null 2>&1 </dev/null)
  n=$(basename $(dirname $c))/$(basename $c)${e:+.elab}
  if cmp -s $T/a.uhdm $T/b.uhdm; then s=$((s+1)); else d=$((d+1)); echo "DIFF $n"; fi
done; done
echo "same=$s diff=$d"; rm -rf $T
