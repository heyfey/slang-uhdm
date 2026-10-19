#!/bin/bash
# offrun.sh <casedir> <binary> <tag> [ENV=VAL]: run with an env var set
c=$1; B=$2; t=$3; shift 3
o=$c/out_$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
