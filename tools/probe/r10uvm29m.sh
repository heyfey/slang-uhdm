#!/bin/bash
# r10uvm29m.sh <sweep-workdir> — THE CLASS-PROPERTY INITIALIZER metric for the
# UVM-4: the r10uvm29v census (each class_defn variable plus a recursive
# projection of its vpiExpr onto the fields uhdm-cmp reads), golden vs ours,
# with the `@line:col` suffix STRIPPED — uhdm-cmp never compares a span, and
# the `uvm_register_cb` macro expansions differ in column per expansion, which
# would otherwise dominate the count.
#
#   R10V=<r10uvm29v build> tools/probe/r10uvm29m.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
V=${R10V:?set R10V to an r10uvm29v build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  [ -f "$G" ] || { echo "$T: no golden"; continue; }
  "$V" "$G"            | sed 's/ @[0-9]*:[0-9]*$//' > /tmp/r10uvm29m.g.$$
  "$V" "$D/slang.uhdm" | sed 's/ @[0-9]*:[0-9]*$//' > /tmp/r10uvm29m.o.$$
  N=$(diff /tmp/r10uvm29m.g.$$ /tmp/r10uvm29m.o.$$ | grep -c '^[<>]')
  echo "$T initdiff=$N"
  TOT=$((TOT+N))
done
rm -f /tmp/r10uvm29m.g.$$ /tmp/r10uvm29m.o.$$
echo "INITTOTAL=$TOT"
