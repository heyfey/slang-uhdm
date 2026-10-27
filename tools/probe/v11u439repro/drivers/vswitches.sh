#!/bin/bash
# usage: vswitches.sh <out.tsv> <pristine> <law> <verified> <casedir>...
# per case: verified under R11U439_OFF against pristine, under R11V439_OFF and
# R11V439_INCDEC_OFF against the law; every run writes the same output path
WR=${WR:-/tmp/v11u439_vsw}; out=$1; P=$2; L=$3; V=$4; shift 4
for b in $P $L $V; do [ -x "$b" ] || { echo "missing $b"; exit 2; }; done
: > $out
for c in "$@"; do
  c=$(readlink -f $c); key="$(basename $(dirname $c))/$(basename $c)"; d=$WR/$(echo $key | tr / _); mkdir -p $d; cp $c/dut.sv $d/dut.sv
  run(){ rm -f $d/out.uhdm; (cd $d && timeout 300 env $1 $2 dut.sv --single-unit --nobuiltin -o out.uhdm >/dev/null 2>&1 </dev/null); echo "$? $(md5sum < $d/out.uhdm 2>/dev/null | cut -c1-12)"; }
  p=$(run X=1 $P); l=$(run X=1 $L); v=$(run X=1 $V); o=$(run R11U439_OFF=1 $V); f=$(run R11V439_OFF=1 $V); i=$(run R11V439_INCDEC_OFF=1 $V)
  echo -e "$key\tp=[$p]\tl=[$l]\tv=[$v]\tU_OFF=$([ "$o" = "$p" ] && echo SAME_AS_PRISTINE || echo DIFF)\tV_OFF=$([ "$f" = "$l" ] && echo SAME_AS_LAW || echo DIFF)\tINCDEC_OFF=$([ "$i" = "$l" ] && echo SAME_AS_LAW || echo DIFF)" >> $out
done
