#!/bin/bash
# r10uvm23m.sh <sweep-workdir> — THE METRIC for § classInheritsContainerImports23.
#
# The pass-19 body-residue metric walks MATCHED task_func bodies, so a listing
# our side never populates is never compared and the whole law is invisible to
# it (pass 22's note).  This one measures the law directly: for every
# class_defn in every view of the UVM-4, diff golden's and our ORDERED
# vpiTaskFunc / vpiTypedef / vpiVariables / vpiParameter / vpiParamAssign
# listings as "<type> '<name>'" lines and report the per-vector diff-line total.
#
#   python3 scripts/verify_golden.py --corpus surelog --mode default \
#     --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
#     --out /tmp/x.csv --workdir /tmp/xw --jobs 2
#   R10B=<r10uvm23b build> tools/probe/r10uvm23m.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
B=${R10B:?set R10B to an r10uvm23b build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$B" "$G" > /tmp/r10uvm23m_g.txt 2>/dev/null
  "$B" "$D/slang.uhdm" > /tmp/r10uvm23m_o.txt 2>/dev/null
  line="$T"
  for k in tf ts var par pas; do
    grep " $k\[" /tmp/r10uvm23m_g.txt | sed 's/\[[0-9]*\]//' > /tmp/r10uvm23m_kg.txt
    grep " $k\[" /tmp/r10uvm23m_o.txt | sed 's/\[[0-9]*\]//' > /tmp/r10uvm23m_ko.txt
    n=$(diff /tmp/r10uvm23m_kg.txt /tmp/r10uvm23m_ko.txt | grep -c '^[<>]')
    line="$line $k=$n"
    TOT=$((TOT + n))
  done
  echo "$line"
done
echo "TOTAL=$TOT"
