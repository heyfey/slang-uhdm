#!/bin/bash
# grid.sh <root> <tag> <bin> [ENV=VAL..]: every dir holding dut.sv under <root>, 3 in parallel, case.sh each; sorted output.
root=$1; tag=$2; bin=$3; shift 3
find $root \( -name dut.sv -o -name dut.v \) -printf '%h\n' | sort -u | xargs -P 3 -I{} $(dirname "$0")/case.sh {} $bin $tag "$@" | sort
