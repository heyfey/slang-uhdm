#!/bin/bash
# r10uvm19p.sh <Test> [outdir] [mode] [only] [filter] — pass-18's p.sh plus the
# fifth argument r10uvm19a.cpp's `tree` mode takes (keep only pairs whose
# "<Lkind> vs <Rkind>" equals it).  R10B defaults to the r10uvm19a build.
set -u
T=$1; O=${2:-/tmp/r10uvm19_m}; M=${3:-part}; ONLY=${4:-}; F=${5:-}
B=${R10B:-/tmp/r10uvm19_t}
SW=${R10W:-/tmp/r10uvm19_u4w}
D=$(ls -d $SW/default/$T-* 2>/dev/null | head -1)
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
$B "$G" "$O/$T.uhdm" "$M" "$ONLY" "$F" 2>/dev/null
