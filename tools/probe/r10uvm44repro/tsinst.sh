#!/bin/bash
# r10uvm44 — the STRING-TYPESPEC INSTANCE residue this pass found while
# measuring its own arm, ranked first for pass 43.  uhdm-cmp RECURSES a
# typespec's vpiInstance, so `@<class>` where golden says `@<package>` is a
# COMPARED difference.  Golden has ZERO class-instanced string_typespecs.
#   usage: tsinst.sh <sweep-workdir>
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
V=/tmp/r10uvm44_r10uvm40av
tot=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$WD"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G" --all > "/tmp/r10uvm44_ti_g_$T.txt" 2>/dev/null
  "$V" "$D/slang.uhdm" --all > "/tmp/r10uvm44_ti_o_$T.txt" 2>/dev/null
  gp=$(grep -c 'ts=string_typespec@uvm_pkg' "/tmp/r10uvm44_ti_g_$T.txt")
  gc=$(grep -oP 'ts=string_typespec@\S+' "/tmp/r10uvm44_ti_g_$T.txt" | grep -vc '@uvm_pkg\|@-')
  op=$(grep -c 'ts=string_typespec@uvm_pkg' "/tmp/r10uvm44_ti_o_$T.txt")
  oc=$(grep -oP 'ts=string_typespec@\S+' "/tmp/r10uvm44_ti_o_$T.txt" | grep -vc '@uvm_pkg\|@-')
  echo "$T golden pkg=$gp class=$gc | ours pkg=$op class=$oc"
  tot=$((tot + oc))
done
echo "TSINSTTOTAL=$tot"
