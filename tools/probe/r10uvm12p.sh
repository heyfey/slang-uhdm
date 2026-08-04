#!/bin/bash
# r10uvm12p.sh <test> [ourdir] [mode] — r10uvm7b on one UVM-4 pair.
set -u
T=$1; O=${2:-/tmp/r10uvm12_m}; M=${3:-part}
D=$(ls -d /tmp/r10uvm11_slw/default/$T-* | head -1)
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$D/cmds.txt" | head -1)/golden.uhdm
/tmp/r10uvm12_b "$G" "$O/$T.uhdm" "$M" 2>/dev/null
