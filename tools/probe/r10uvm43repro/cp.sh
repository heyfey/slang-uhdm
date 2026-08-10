#!/bin/bash
# r10uvm43 — run the CONTAINER-POSITION census (r10uvm43cp) on golden and ours
# for one UVM-4 test out of a sweep workdir, and diff them.
#   usage: cp.sh <sweep-workdir> <tag> <test> [nameFilter]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
TAG=${2:?}
T=${3:?}
F=${4:-}
V=/tmp/r10uvm43_r10uvm43cp
D=$(ls -d "$WD"/default/$T-* 2>/dev/null | head -1)
[ -n "$D" ] || { echo "$T: no workdir under $WD"; exit 1; }
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
"$V" "$G" "$F" > "/tmp/r10uvm43_cp_g_$T.txt" 2>/dev/null
"$V" "$D/slang.uhdm" "$F" > "/tmp/r10uvm43_cp_${TAG}_$T.txt" 2>/dev/null
echo "$T golden=$(wc -l < "/tmp/r10uvm43_cp_g_$T.txt") ours=$(wc -l < "/tmp/r10uvm43_cp_${TAG}_$T.txt") diff=$(diff "/tmp/r10uvm43_cp_g_$T.txt" "/tmp/r10uvm43_cp_${TAG}_$T.txt" | grep -c '^[<>]')"
