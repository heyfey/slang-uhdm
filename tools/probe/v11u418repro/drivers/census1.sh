#!/bin/bash
# census1.sh <casedir>: pristine, law and verified slang-uhdm on one earlier-pass case dir (no golden);
# prints exit codes and whether law / verified bytes equal pristine's
c=$(cd $1 && pwd); k=$(echo $c | sed 's|.*/tools/probe/||; s|/|_|g'); o=/tmp/v11u418_census/$k; rm -rf $o; mkdir -p $o
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
[ -f $c/dut.sv ] || [ -f $c/FILES ] || { echo "$k NOSRC"; exit; }
for b in pristine law verified; do (cd $c && timeout 300 /tmp/v11u418_bin/$b $SRC $GT --single-unit --nobuiltin -o $o/$b.uhdm > /dev/null 2>&1; echo $? > $o/$b.rc); done
m(){ md5sum < $o/$1.uhdm 2>/dev/null | cut -c1-12; }
echo "$k rc=$(cat $o/pristine.rc)/$(cat $o/law.rc)/$(cat $o/verified.rc) law=$([ "$(m law)" = "$(m pristine)" ] && echo same || echo MOVED) verified=$([ "$(m verified)" = "$(m pristine)" ] && echo same || echo MOVED) v_vs_law=$([ "$(m verified)" = "$(m law)" ] && echo same || echo DIFF)"
