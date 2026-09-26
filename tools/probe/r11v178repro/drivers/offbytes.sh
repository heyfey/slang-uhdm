#!/bin/bash
# offbytes.sh <binary> <pristine probe workdir> <list of probe db basenames> [ENV=VAL ...]
# Re-export each probe case with <binary> under the given environment and compare its bytes with the pristine sweep's
# database of the same case.  Prints SAME/DIFF per case and a tally.  Probe cases only (no corpus source is read).
set -u; B=$1; PW=$2; L=$3; shift 3
T=/tmp/v11u178_offb.$$; mkdir -p $T; same=0; diff=0
while read -r db <&3; do
  rel=${db%.uhdm}; rel=${rel//__//}; d=/tmp/wt_v11u178/tests/probe/$rel
  [ -f $d/dut.sv ] || { echo "NOCASE $db"; continue; }
  rm -f $T/o.uhdm; (cd $d && env "$@" $B dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1 </dev/null)
  if cmp -s $T/o.uhdm $PW/$db; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $db"; fi
done 3< $L
echo "same=$same diff=$diff"; rm -rf $T
