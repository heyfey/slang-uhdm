#!/bin/bash
# offrun.sh <casedir> <binary> <tag> <builtin 0|1> [ENV=VAL]: run with an env var set
c=$1; B=$2; t=$3; bi=$4; shift 4
nb="--nobuiltin"; [ "$bi" = 1 ] && nb=""
o=$c/out_$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B dut.sv --single-unit $nb -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
