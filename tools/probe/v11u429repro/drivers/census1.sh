#!/bin/bash
# census1.sh <casedir rel to tools/probe>: run pristine and law, print rc and md5 for both
c=/tmp/wt_v11u429/tools/probe/$1; [ -f $c/dut.sv ] || [ -f $c/FILES ] || { echo "$1 NOSRC"; exit; }
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
o=/tmp/v11u429_cen/$(echo $1 | tr / _); mkdir -p $o; out=
for t in pris law; do rm -f $o/$t.uhdm; (cd $c && timeout 300 /tmp/v11u429_$t/slang-uhdm $SRC $GT --single-unit --nobuiltin -o $o/$t.uhdm >/dev/null 2>&1); r=$?; m=$(md5sum < $o/$t.uhdm 2>/dev/null | cut -c1-8); out="$out $t:rc=$r:${m:-none}"; done
echo "$1$out"
