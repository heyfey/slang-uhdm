#!/bin/bash
# r10uvm25m.sh <sweep-workdir> — the PACKAGE-listing metric for
# § importPublishesPackageClasses24's two views.  r10uvm23m.sh measures the
# CLASS listings; this one measures each package view's own vpiTypedef listing
# (DEFPKG = design->AllPackages, ELABPKG = design->TopPackages), which is where
# the pass-24 law is actually applied and where its def-view arm was missing.
#
# Normalizes away the listing index and the vpiParent column (uhdm-cmp compares
# neither), so a reported line is a real VpiType/VpiName/target difference.
#
#   R10P=<r10uvm24p build> tools/probe/r10uvm25m.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
P=${R10P:?set R10P to an r10uvm24p build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$P" "$G" > /tmp/r10uvm25m_g.txt 2>/dev/null
  "$P" "$D/slang.uhdm" > /tmp/r10uvm25m_o.txt 2>/dev/null
  line="$T"
  for V in DEFPKG ELABPKG; do
    grep "^$V" /tmp/r10uvm25m_g.txt | sed -e 's/ ts\[[0-9]*\]/ ts/' -e 's/ par=.*//' > /tmp/r10uvm25m_kg.txt
    grep "^$V" /tmp/r10uvm25m_o.txt | sed -e 's/ ts\[[0-9]*\]/ ts/' -e 's/ par=.*//' > /tmp/r10uvm25m_ko.txt
    miss=$(diff /tmp/r10uvm25m_kg.txt /tmp/r10uvm25m_ko.txt | grep -c '^<')
    extra=$(diff /tmp/r10uvm25m_kg.txt /tmp/r10uvm25m_ko.txt | grep -c '^>')
    line="$line $V=-$miss/+$extra"
    TOT=$((TOT + miss + extra))
  done
  echo "$line"
done
echo "PKGTOTAL=$TOT"
