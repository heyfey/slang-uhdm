#!/bin/bash
# census1.sh <casedir relative to tools/probe>: run pristine and law on one earlier-pass case dir; print rc and md5 of each
c=/tmp/wt_v11u434/tools/probe/$1; key=$(echo $1 | sed 's|^\./||; s|/|_|g'); o=/tmp/v11u434_cen/$key; rm -rf $o; mkdir -p $o
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
r=""
for b in pristine law; do
  (cd $c && timeout 300 /tmp/v11u434_bin/$b $SRC $GT --single-unit --nobuiltin -o $o/$b.uhdm > $o/$b.log 2>&1; echo $? > $o/$b.rc)
  m=NONE; [ -s $o/$b.uhdm ] && m=$(md5sum < $o/$b.uhdm | cut -c1-12)
  r="$r $b rc=$(cat $o/$b.rc) $m"
done
echo "$1$r"
