#!/bin/bash
# r10uvm26m.sh <sweep-workdir> [pkgFilter] — THE VARIABLE-listing metric for the
# UVM-4: the r10uvm26v census (kind / vpiAutomatic / vpiConstantVariable /
# vpiVisibility / vpiExpr kind, per package view), golden vs ours, normalized
# for the listing index only.  Pass 25's listing metrics (r10uvm23m class
# listings, r10uvm25m package vpiTypedef listings) read 0 while this one read
# 144 — the variables' own FIELDS were the whole remaining residue.
#
#   R10V=<r10uvm26v build> tools/probe/r10uvm26m.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
F=${2:-}
V=${R10V:?set R10V to an r10uvm26v build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G" $F | sed 's/var\[[0-9]*\]/var/' > /tmp/r10uvm26m_g.txt 2>/dev/null
  "$V" "$D/slang.uhdm" $F | sed 's/var\[[0-9]*\]/var/' > /tmp/r10uvm26m_o.txt 2>/dev/null
  line="$T"
  for VW in DEFPKG ELABPKG; do
    grep "^$VW" /tmp/r10uvm26m_g.txt > /tmp/r10uvm26m_kg.txt
    grep "^$VW" /tmp/r10uvm26m_o.txt > /tmp/r10uvm26m_ko.txt
    miss=$(diff /tmp/r10uvm26m_kg.txt /tmp/r10uvm26m_ko.txt | grep -c '^<')
    extra=$(diff /tmp/r10uvm26m_kg.txt /tmp/r10uvm26m_ko.txt | grep -c '^>')
    line="$line $VW=-$miss/+$extra"
    TOT=$((TOT + miss + extra))
  done
  echo "$line"
done
echo "VARTOTAL=$TOT"
