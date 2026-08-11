#!/bin/bash
# r10uvm47 (cloned from pass 46) (cloned from pass 45) (cloned from pass 44) — run the CONTAINER-POSITION census (r10uvm44cp) on golden and ours
# for one UVM-4 test out of a sweep workdir, and diff them.
#   usage: cp.sh <sweep-workdir> <tag> <test> [nameFilter]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
TAG=${2:?}
T=${3:?}
F=${4:-}
# The PROBE's own name keeps its birth pass (r10uvm43cp); only the /tmp
# NAMESPACE prefix moves to this pass.  clone43.sh's blanket rename got this
# wrong and the driver then silently reported `golden=0 ours=0 diff=0` for every
# test — A DRIVER THAT CANNOT FIND ITS PROBE REPORTS PERFECTION.
V=/tmp/r10uvm47_r10uvm43cp
D=$(ls -d "$WD"/default/$T-* 2>/dev/null | head -1)
[ -n "$D" ] || { echo "$T: no workdir under $WD"; exit 1; }
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
"$V" "$G" "$F" > "/tmp/r10uvm47_cp_g_$T.txt" 2>/dev/null
"$V" "$D/slang.uhdm" "$F" > "/tmp/r10uvm47_cp_${TAG}_$T.txt" 2>/dev/null
echo "$T golden=$(wc -l < "/tmp/r10uvm47_cp_g_$T.txt") ours=$(wc -l < "/tmp/r10uvm47_cp_${TAG}_$T.txt") diff=$(diff "/tmp/r10uvm47_cp_g_$T.txt" "/tmp/r10uvm47_cp_${TAG}_$T.txt" | grep -c '^[<>]')"
