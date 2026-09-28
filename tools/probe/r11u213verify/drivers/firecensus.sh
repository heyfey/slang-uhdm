#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208) firecensus.sh <trace dir> <dir under tools/probe>...: the fix's firing census over case directories: every
# dir holding a dut.sv / dut.v (an `args` file names several roots) is run once per view (default; --elabuhdm) by
# fix.bin with R11V213_TRACE=<trace dir> (r11u213); the trace files (first line `OUT <db>`) name every firing.  Paths naming a
# fenced test are dropped before anything runs; a non-zero rc of fix.bin re-runs law.bin on the same case-view
# and is logged in <trace dir>.rc (fail-closed on $FENCED, drivers/env.sh).  Three cases at a time.
source "$(dirname "$0")/env.sh" || exit 2
TR=$1; shift; mkdir -p $TR; T=/tmp/r11u213_fc; mkdir -p $T
one() {
  c=$1; k=$(echo $c | md5sum | cut -c1-12)
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  for el in "" "--elabuhdm"; do
    o=$T/$k${el:+_el}.uhdm; rm -f $o
    (cd $c && R11V213_TRACE=$TR timeout 300 $FIX $SRC --single-unit --nobuiltin $el -o $o > /dev/null 2>&1); rc=$?
    if [ $rc != 0 ]; then
      # a failing case-view: the law binary on the same input (a crash of the fix alone is a BREAK of the fix)
      rm -f $o.law; (cd $c && timeout 300 $LAW $SRC --single-unit --nobuiltin $el -o $o.law > /dev/null 2>&1); rl=$?
      echo "RC ${c#$R213_ROOT/tools/probe/}${el:+ el} fix=$rc law=$rl" >> $TR.rc; rm -f $o.law
    fi
    rm -f $o
  done
}
export -f one; export T TR FIX LAW R213_ROOT
for d in "$@"; do find $R213_ROOT/tools/probe/$d \( -name dut.sv -o -name dut.v \) -printf '%h\n'; done | sort -u | grep -vP "$FENCE_RE" > $TR.list
while read -r c; do echo "$(echo $c | md5sum | cut -c1-12) ${c#$R213_ROOT/tools/probe/}"; done < $TR.list > $TR.map
xargs -P 3 -I{} bash -c 'one {}' < $TR.list
echo "FIRECENSUS_DONE cases=$(wc -l < $TR.list) trace_files=$(ls $TR | wc -l)"
