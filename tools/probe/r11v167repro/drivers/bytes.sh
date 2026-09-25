#!/bin/bash
# bytes.sh <tag> <pristine> <other> <envassign|-> <dir>...: SAME/DIFF per dut.sv (pristine vs other with env)
: ${FENCED:?}
T=$1; P=$2; L=$3; E=$4; shift 4; W=/tmp/v11u167_bytes_$T; mkdir -p $W; n=0; d=0
for c in $(find "$@" -name dut.sv | sort); do
  skip=0; for f in $FENCED; do grep -qw "$f" <<<"$c" && skip=1; done; [ $skip = 1 ] && { echo "FENCED-SKIP"; continue; }
  dir=$(dirname $c); k=$(echo $dir | md5sum | cut -c1-12)
  rm -f $W/$k.p $W/$k.l
  (cd $dir && $P dut.sv --single-unit --nobuiltin -o $W/$k.p >/dev/null 2>&1)
  if [ "$E" = - ]; then (cd $dir && $L dut.sv --single-unit --nobuiltin -o $W/$k.l >/dev/null 2>&1)
  else (cd $dir && env $E $L dut.sv --single-unit --nobuiltin -o $W/$k.l >/dev/null 2>&1); fi
  n=$((n+1)); if [ ! -e $W/$k.p ] && [ ! -e $W/$k.l ]; then echo "SAME(no database on either) $dir"; elif cmp -s $W/$k.p $W/$k.l; then echo "SAME $dir"; else echo "DIFF $dir"; d=$((d+1)); fi
done
echo "$T: $((n-d)) of $n byte-identical"
