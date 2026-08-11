#!/bin/bash
# r10uvm46 (cloned from pass 45) (cloned from pass 44) — one sub-class of the CPTOTAL residue: an array-of-class-handles
# ELEMENT typespec.  Golden names it after the CLASS and spans it at the
# declaration's TYPE text; ours emits an UNNAMED class_typespec spanned at the
# declaration.  VpiName is a COMPARED field, so this is cmp-relevant.
#   usage: cpclass.sh <tag>
set -u
TAG=${1:?}
tg=0; to=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  G=/tmp/r10uvm46_cp_g_$T.txt
  O=/tmp/r10uvm46_cp_${TAG}_$T.txt
  [ -s "$G" ] && [ -s "$O" ] || { echo "$T: census missing (run cp.sh)"; continue; }
  g=$(diff "$G" "$O" | grep -c "^< .*elem=class_typespec'[A-Za-z_]")
  o=$(diff "$G" "$O" | grep -c "^> .*elem=class_typespec'<unnamed>")
  echo "$T goldenNamedClassElem=$g oursUnnamedClassElem=$o"
  tg=$((tg+g)); to=$((to+o))
done
echo "CPCLASS golden-side=$tg ours-side=$to"
