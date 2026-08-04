#!/bin/bash
# r10uvm15p.sh <Test> [outdir] [mode] [only] — r10uvm7b over ONE already-emitted
# UVM-4 pair (outdir written by r10uvm15m.sh).  mode = part (default) | rows
set -u
T=$1; O=${2:-/tmp/r10uvm15_m}; M=${3:-part}; ONLY=${4:-}
B=${R10B:-/tmp/r10uvm15_b}
SW=${R10W:-/tmp/r10uvm15_u4w}
D=$(ls -d $SW/default/$T-* 2>/dev/null | head -1)
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$D/cmds.txt" | head -1)/golden.uhdm
$B "$G" "$O/$T.uhdm" "$M" "$ONLY" 2>/dev/null
