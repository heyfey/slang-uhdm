#!/bin/bash
# r10uvm13p.sh <Test> [outdir] [mode] — r10uvm7b over ONE already-emitted UVM-4
# pair (outdir written by r10uvm13m.sh).  mode = part (default) | rows
set -u
T=$1; O=${2:-/tmp/r10uvm13_m}; M=${3:-part}
B=${R10B:-/tmp/r10uvm13_b}
D=$(ls -d /tmp/r10uvm11_slw/default/$T-* 2>/dev/null | head -1)
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$D/cmds.txt" | head -1)/golden.uhdm
$B "$G" "$O/$T.uhdm" "$M" 2>/dev/null
