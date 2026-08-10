#!/bin/bash
# r10uvm41 — the r10uvm41ts named-typespec residue against golden.
#   usage: tsres.sh <sweep-workdir> <tag>
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
TAG=${2:?}
V=/tmp/r10uvm41_r10uvm41ts
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$WD"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G" > "/tmp/r10uvm41_ts_g_$T.txt" 2>/dev/null
  "$V" "$D/slang.uhdm" > "/tmp/r10uvm41_ts_${TAG}_$T.txt" 2>/dev/null
  n=$(diff "/tmp/r10uvm41_ts_g_$T.txt" "/tmp/r10uvm41_ts_${TAG}_$T.txt" | grep -c '^[<>]')
  echo "$T tsdiff=$n (golden $(wc -l < /tmp/r10uvm41_ts_g_$T.txt) rows, ours $(wc -l < /tmp/r10uvm41_ts_${TAG}_$T.txt))"
done
