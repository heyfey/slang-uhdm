#!/bin/bash
# away1.sh <casedir relative to tools/probe>: pristine vs law bytes and exit codes (no golden)
d=/tmp/wt_v11u469/tools/probe/$1; W=/tmp/v11u469_away/$1; mkdir -p $W
args="dut.sv --single-unit --nobuiltin"; [ -f $d/args.txt ] && args=$(cat $d/args.txt)
for t in pristine law; do rm -f $W/$t.uhdm; (cd $d && timeout 300 /tmp/v11u469_bin/$t dut.sv --single-unit --nobuiltin -o $W/$t.uhdm > $W/$t.log 2>&1 </dev/null); echo $? > $W/$t.rc; done
s=$(cmp -s $W/pristine.uhdm $W/law.uhdm && echo same || echo MOVED)
echo "$1 pr=$(cat $W/pristine.rc) law=$(cat $W/law.rc) $s"
