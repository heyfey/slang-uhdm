#!/bin/bash
# r10uvm41 — the r10uvm28a package-listing residue (line count per test) and
# the element-head hash, on one sweep workdir.  The DESIGN head alone lies
# (visited-set), which is why this cross-check exists.
#   usage: listres.sh <sweep-workdir> <tag>
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
TAG=${2:?}
V=/tmp/r10uvm41_r10uvm28a
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$WD"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G" "$D/slang.uhdm" > "/tmp/r10uvm41_28a_${TAG}_$T.txt" 2>/dev/null
  echo "$T lines=$(wc -l < /tmp/r10uvm41_28a_${TAG}_$T.txt) head=$(head -1 /tmp/r10uvm41_28a_${TAG}_$T.txt | md5sum | cut -c1-12)"
done
