#!/bin/bash
# pair.sh <casedir> <binary> [ENV..] : prints golden path and our db path
c=$(readlink -f $1); B=$2; shift 2
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16); G=/tmp/v11u421_gold/$h
tag=$(echo "$c $B $*" | md5sum | cut -c1-12)
echo $G/golden.uhdm /tmp/v11u421_scr/o_$tag.uhdm
