#!/bin/bash
# r10uvm46 (cloned from pass 45) — the interface_inst POPULATION of golden vs ours for one test, the
# residue § 5(1) ranks first for pass 46.
#
# `SimpleUVM` golden holds THREE interface_inst objects (an unnamed def view plus
# `add_sub_if0` TWICE) where we hold two — a missing OBJECT, i.e. the
# `r=1 failLhs=<container>` vector-SIZE class.  The source is
# `bind ADD_SUB add_sub_if add_sub_if0(...)` into a module that is itself
# instantiated.  `InterfaceBinding` is already CMP_EQUAL with DUMP=match, so it
# is the DISTINGUISHER: run this on both and read what differs.
#   usage: ifcount.sh <sweep-workdir> <test> [mode]
set -u
WD=${1:?}
T=${2:?}
MODE=${3:-default}
V=/tmp/r10uvm46_r10uvm44ls
[ -x "$V" ] || { echo "FATAL: probe $V missing"; exit 3; }
D=$(ls -d "$WD/$MODE/$T"-* 2>/dev/null | head -1)
[ -n "$D" ] || { echo "$T: no workdir under $WD/$MODE"; exit 1; }
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
[ -f "$G" ] || { echo "FATAL: golden $G missing"; exit 3; }
"$V" "$G" > "/tmp/r10uvm46_ifc_g_$T.txt"
"$V" "$D/slang.uhdm" > "/tmp/r10uvm46_ifc_o_$T.txt"
for f in "/tmp/r10uvm46_ifc_g_$T.txt" "/tmp/r10uvm46_ifc_o_$T.txt"; do
  [ -s "$f" ] || { echo "FATAL: $f EMPTY"; exit 3; }
done
echo "$T golden interface_inst=$(grep -c '^interface_inst' "/tmp/r10uvm46_ifc_g_$T.txt") ours=$(grep -c '^interface_inst' "/tmp/r10uvm46_ifc_o_$T.txt")"
echo "-- golden:"; grep '^interface_inst' "/tmp/r10uvm46_ifc_g_$T.txt" | cut -c1-110
echo "-- ours:";   grep '^interface_inst' "/tmp/r10uvm46_ifc_o_$T.txt" | cut -c1-110
