#!/bin/bash
# r10uvm16p.sh <Test> [outdir] [mode] [only] — run a probe binary (R10B, default
# /tmp/r10uvm16_b) over ONE already-emitted UVM-4 pair (outdir written by
# r10uvm16m.sh).  mode = part (default) | rows | why | whycls
set -u
T=$1; O=${2:-/tmp/r10uvm16_m}; M=${3:-part}; ONLY=${4:-}
B=${R10B:-/tmp/r10uvm16_b}
SW=${R10W:-/tmp/r10uvm16_u4w}
D=$(ls -d $SW/default/$T-* 2>/dev/null | head -1)
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$D/cmds.txt" | head -1)/golden.uhdm
$B "$G" "$O/$T.uhdm" "$M" "$ONLY" 2>/dev/null
