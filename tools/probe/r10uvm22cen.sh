#!/bin/bash
# r10uvm22cen.sh <ourdir> <censusdir> — build the per-test FOREACH LOOP-VARIABLE
# census (r10uvm20a) for golden and for us, into <censusdir>/cen_{g,o}_<test>.txt,
# then rank the disagreements with r10uvm22cendiff.py.  <ourdir> is the
# r10uvm19m.sh output directory; goldens come from the sweep workdir (R10W).
#
#   python3 scripts/verify_golden.py --corpus surelog --mode default \
#     --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
#     --out /tmp/x.csv --workdir /tmp/xw --jobs 2
#   R10B=<r10uvm7b build> R10W=/tmp/xw tools/probe/r10uvm19m.sh <su> /tmp/m
#   R10W=/tmp/xw R10A=<r10uvm20a build> tools/probe/r10uvm22cen.sh /tmp/m /tmp/cen
set -u
O=${1:?ourdir}
C=${2:-/tmp/r10uvm22cen}
SW=${R10W:?set R10W to the sweep workdir}
A=${R10A:?set R10A to an r10uvm20a build}
P=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$C"
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$A" "$G" 2>/dev/null | sed "s/^/$T /" > "$C/cen_g_$T.txt"
  "$A" "$O/$T.uhdm" 2>/dev/null | sed "s/^/$T /" > "$C/cen_o_$T.txt"
done
python3 "$P/r10uvm22cendiff.py" "$C"
