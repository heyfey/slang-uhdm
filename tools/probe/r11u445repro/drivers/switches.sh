#!/bin/bash
# usage: switches.sh <grid.tsv from grid.sh with pris + law columns> <law binary> <ENV assignment ...>
# reruns <law binary> with the given env on every grid case dir and compares its md5 with the pris column
G=$1; L=$2; shift 2; WR=${WR:-/tmp/r11u445_grid}
[ -x "$L" ] || { echo "missing $L"; exit 2; }
n=0; same=0
while IFS=$'\t' read -r key slrc pris rest; do
  d=$WR/$(echo $key | tr / _); pm=$(echo "$pris" | sed 's/.*md5=\([0-9a-f]*\).*/\1/'); prc=$(echo "$pris" | sed 's/.*rc=\([0-9]*\).*/\1/')
  rm -f $d/out_sw.uhdm
  (cd $d && env "$@" timeout 300 $L dut.sv --single-unit --nobuiltin -o out_sw.uhdm >/dev/null 2>&1 </dev/null); rc=$?
  m=$(md5sum < $d/out_sw.uhdm | cut -c1-8); n=$((n+1))
  if [ "$m" = "$pm" ] && [ "$rc" = "$prc" ]; then same=$((same+1)); else echo "DIFF $key rc=$rc md5=$m pris=$pm"; fi
done < $G
echo "SAME $same of $n ($*)"
