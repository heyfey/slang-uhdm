#!/bin/bash
# away.sh <pristine> <law> <list of case dut.sv paths (repo-relative)> <out dir>
# single process: both binaries from the case's own directory (dut.sv --single-unit
# --nobuiltin); prints rc and md5 per binary and the law's trace firings (R11U479_TRACE).
A=$1; B=$2; L=$3; O=$4; R=/home/heyfey/git-repos/slang-uhdm
[ -x "$A" ] && [ -x "$B" ] || { echo "binary missing"; exit 1; }
mkdir -p $O/db $O/tr; : > $O/away.tsv
while IFS= read -r f <&3; do
  d=$(dirname "$f"); k=$(echo "$d" | tr / _)
  rm -f $O/db/$k.A.uhdm $O/db/$k.B.uhdm; rm -rf $O/tr/$k; mkdir -p $O/tr/$k
  (cd $R/$d && "$A" dut.sv --single-unit --nobuiltin -o $O/db/$k.A.uhdm >/dev/null 2>&1 </dev/null); ra=$?
  (cd $R/$d && R11U479_TRACE=$O/tr/$k "$B" dut.sv --single-unit --nobuiltin -o $O/db/$k.B.uhdm >/dev/null 2>&1 </dev/null); rb=$?
  ma=$( [ -f $O/db/$k.A.uhdm ] && md5sum < $O/db/$k.A.uhdm | cut -c1-10 || echo -)
  mb=$( [ -f $O/db/$k.B.uhdm ] && md5sum < $O/db/$k.B.uhdm | cut -c1-10 || echo -)
  nf=$(cat $O/tr/$k/* 2>/dev/null | grep -vc '^OUT ')
  echo -e "$d\t$ra\t$ma\t$rb\t$mb\t$nf" >> $O/away.tsv
  [ "$ma" = "$mb" ] && rm -f $O/db/$k.A.uhdm $O/db/$k.B.uhdm
done 3< "$L"
echo done $(wc -l < $O/away.tsv)
