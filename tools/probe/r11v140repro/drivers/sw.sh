#!/usr/bin/env bash
# sw.sh <case dir> <ENV=1> <ref bin name>: run ver1 under env, compare bytes to <ref>.uhdm
c=$(realpath ${1%/}); e=$2; ref=$3
o=/tmp/v11u140_scratch/sw_tmp_$$.uhdm; rm -f $o
(cd $c && env $e /tmp/v11u140_bin/ver1 dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1)
cmp -s $o $c/$ref.uhdm && echo "SAME $e $ref $(basename $c)" || echo "DIFF $e $ref $(basename $c)"
rm -f $o
