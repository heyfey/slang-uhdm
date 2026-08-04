#!/bin/bash
# r10uvm11d.sh <tag> <view> <fn>... — per-subroutine dump diff of a repro pair.
set -u
T=$1; V=$2; shift 2
uhdm-dump /tmp/r10uvm11_${T}_g${V}.uhdm > /tmp/r10uvm11_${T}_g${V}.txt 2>&1
uhdm-dump /tmp/r10uvm11_${T}_s${V}.uhdm > /tmp/r10uvm11_${T}_s${V}.txt 2>&1
for f in "$@"; do
  echo "### $f"
  sed -n "/::$f), line:/,/vpiMethod:/p" /tmp/r10uvm11_${T}_g${V}.txt > /tmp/r10uvm11_dg.txt
  sed -n "/::$f), line:/,/vpiMethod:/p" /tmp/r10uvm11_${T}_s${V}.txt > /tmp/r10uvm11_ds.txt
  diff /tmp/r10uvm11_dg.txt /tmp/r10uvm11_ds.txt | head -30
done
