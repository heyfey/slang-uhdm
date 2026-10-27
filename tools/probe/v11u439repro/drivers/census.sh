#!/bin/bash
# usage: census.sh <list of absolute .sv paths> <out.tsv> <pristine> <law>
# each source copied to its own dir under $WR (default /tmp/v11u439_cen), run by both
# binaries writing the same output path; prints rc and md5 per binary
L=$1; out=$2; P=$3; W=$4; WR=${WR:-/tmp/v11u439_cen}
[ -x "$P" ] && [ -x "$W" ] || { echo missing binary; exit 2; }
: > $out; n=0
while read f; do
  n=$((n+1)); d=$WR/$n; mkdir -p $d; cp "$f" $d/dut.sv
  run(){ rm -f $d/out.uhdm; (cd $d && timeout 120 $1 dut.sv --single-unit --nobuiltin -o out.uhdm >/dev/null 2>&1 </dev/null); local rc=$?; echo "$rc $(md5sum < $d/out.uhdm 2>/dev/null | cut -c1-12)"; mv -f $d/out.uhdm $d/$2.uhdm 2>/dev/null; }
  p=$(run $P p); l=$(run $W l)
  echo -e "$n\t$f\t$p\t$l\t$([ "$p" = "$l" ] && echo SAME || echo MOVED)" >> $out
done < $L
