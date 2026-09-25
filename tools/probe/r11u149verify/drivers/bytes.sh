#!/bin/bash
# bytes.sh <binA> <binB> <dir>...: run both binaries on every dut.sv under the dirs (plain and --elabuhdm) and list the
# case databases whose bytes differ.  No goldens; a byte control.  Prints PROCESSED/LISTED at the end.
A=$1; B=$2; shift 2; n=0; m=0; t=/tmp/r11u149_bytes_$$; mkdir -p $t
exec 3< <(find "$@" -name dut.sv | sort)
while read -u 3 f; do
  d=$(dirname $f); n=$((n+1))
  for x in "" --elabuhdm; do
    rm -f $t/a.uhdm $t/b.uhdm
    (cd $d && $A dut.sv --single-unit --nobuiltin $x -o $t/a.uhdm </dev/null >/dev/null 2>&1); ra=$?
    (cd $d && $B dut.sv --single-unit --nobuiltin $x -o $t/b.uhdm </dev/null >/dev/null 2>&1); rb=$?
    # both rejected with no database is not a mover (v11u137 h07 reads rc=3 on both binaries)
    if [ ! -e $t/a.uhdm ] && [ ! -e $t/b.uhdm ] && [ $ra = $rb ]; then continue; fi
    if ! cmp -s $t/a.uhdm $t/b.uhdm || [ $ra != $rb ]; then m=$((m+1)); echo "MOVER ${d#/tmp/wt_r11u149/tools/probe/} ${x:-plain} rc=$ra/$rb"; fi
  done
done
echo "PROCESSED=$n LISTED=$(find "$@" -name dut.sv | wc -l) MOVERS=$m"
rm -rf $t
