#!/bin/bash
# census.sh <pristine> <law> <listfile> <outdir>: run both binaries on every case dir in the list
# (dut.sv, or FILES / TOP as run1.sh reads them) and print one line per dir:
#   dir rcP rcL same|BYTES|NOUHDM
P=$1; L=$2; LIST=$3; O=$4; mkdir -p $O
while read d; do
  c=/tmp/wt_v11u422/tools/probe/$d
  SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
  GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  k=$(echo $d | tr / _)
  rm -f $O/$k.p.uhdm $O/$k.l.uhdm
  (cd $c && timeout 300 $P $SRC $GT --single-unit --nobuiltin -o $O/$k.p.uhdm >/dev/null 2>&1; echo $? > $O/$k.p.rc)
  (cd $c && timeout 300 $L $SRC $GT --single-unit --nobuiltin -o $O/$k.l.uhdm >/dev/null 2>&1; echo $? > $O/$k.l.rc)
  rp=$(cat $O/$k.p.rc); rl=$(cat $O/$k.l.rc)
  if [ ! -f $O/$k.p.uhdm ] && [ ! -f $O/$k.l.uhdm ]; then v=NOUHDM
  elif cmp -s $O/$k.p.uhdm $O/$k.l.uhdm; then v=same; rm -f $O/$k.p.uhdm $O/$k.l.uhdm
  else v=BYTES; fi
  echo "$d $rp $rl $v"
done < $LIST
