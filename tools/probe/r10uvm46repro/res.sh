#!/bin/bash
# r10uvm46 (cloned from pass 45) (cloned from pass 44) — the three whole-census residues against golden on one sweep
# workdir: r10uvm28a (package listing), r10uvm41ts (named typespecs, span
# aware) and r10uvm42tw (twin USE: which listing object / clone each reference
# position takes).
#   usage: res.sh <sweep-workdir> <tag> [probe]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
TAG=${2:?}
ONLY=${3:-}
for PR in r10uvm28a r10uvm41ts r10uvm42tw; do
  [ -n "$ONLY" ] && [ "$ONLY" != "$PR" ] && continue
  V=/tmp/r10uvm46_$PR
  [ -x "$V" ] || { echo "$PR: no binary"; continue; }
  echo "## $PR"
  for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
    D=$(ls -d "$WD"/default/$T-* 2>/dev/null | head -1)
    [ -n "$D" ] || { echo "$T: no workdir"; continue; }
    G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
    if [ "$PR" = r10uvm28a ]; then
      # r10uvm28a takes BOTH databases and prints the residue itself.
      "$V" "$G" "$D/slang.uhdm" > "/tmp/r10uvm46_${PR}_${TAG}_$T.txt" 2>/dev/null
      echo "$T lines=$(wc -l < "/tmp/r10uvm46_${PR}_${TAG}_$T.txt") head=$(head -1 "/tmp/r10uvm46_${PR}_${TAG}_$T.txt" | md5sum | cut -c1-12)"
    else
      "$V" "$G" > "/tmp/r10uvm46_${PR}_g_$T.txt" 2>/dev/null
      "$V" "$D/slang.uhdm" > "/tmp/r10uvm46_${PR}_${TAG}_$T.txt" 2>/dev/null
      n=$(diff "/tmp/r10uvm46_${PR}_g_$T.txt" "/tmp/r10uvm46_${PR}_${TAG}_$T.txt" | grep -c '^[<>]')
      echo "$T diff=$n (golden $(wc -l < "/tmp/r10uvm46_${PR}_g_$T.txt"), ours $(wc -l < "/tmp/r10uvm46_${PR}_${TAG}_$T.txt"))"
    fi
  done
done
