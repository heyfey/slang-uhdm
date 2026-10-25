#!/bin/bash
# census.sh <listfile> <binA> <binB> <outdir>: byte census of case dirs (paths relative to tools/probe):
# runs both binaries as run1.sh does (dut.sv or FILES, TOP), prints SAME/MOVED with both exit codes
L=$1; A=$2; B=$3; O=$4; P=/tmp/wt_v11u430/tools/probe
[ -x "$A" ] && [ -x "$B" ] || exit 2
mkdir -p $O
while read d; do
  c=$P/$d; [ -d "$c" ] || continue
  SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
  [ -f $c/FILES ] || [ -f $c/dut.sv ] || { echo "NOSRC $d"; continue; }
  GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  k=$(echo $d | tr / _); rm -f $O/$k.a $O/$k.b
  (cd $c && timeout 300 $A $SRC $GT --single-unit --nobuiltin -o $O/$k.a >/dev/null 2>&1); ra=$?
  (cd $c && timeout 300 $B $SRC $GT --single-unit --nobuiltin -o $O/$k.b >/dev/null 2>&1); rb=$?
  if [ ! -e $O/$k.a ] && [ ! -e $O/$k.b ] && [ $ra = $rb ]; then echo "SAME_NODB $d rc=$ra"; continue; fi
  if cmp -s $O/$k.a $O/$k.b && [ $ra = $rb ]; then echo "SAME $d rc=$ra"; rm -f $O/$k.a $O/$k.b; else echo "MOVED $d rcA=$ra rcB=$rb"; fi
done < $L
