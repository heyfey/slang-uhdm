#!/bin/bash
# grid.sh <binary> <tag> <casedir>... : case.sh over every case dir (a dir holding dut.sv or files), one line each
set -u; BIN=$1; T=$2; shift 2
D=$(dirname $(readlink -f $0))
for c in "$@"; do find $c \( -name dut.sv -o -name files \) -printf '%h\n'; done | sort -u | while read c; do
  TAG=$T bash $D/case.sh $c $BIN </dev/null
done
