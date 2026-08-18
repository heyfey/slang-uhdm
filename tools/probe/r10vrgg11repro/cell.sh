#!/usr/bin/env bash
# r10vrgg11 — ONE adversarial cell: golden once, then OUR side per binary tag.
# Separate FILE (export -f does not survive into xargs children).
# </dev/null on the CHILD, never on xargs.
set -u
d=$1; O=$2; BIN=$3; TAG=$4
n=$(basename "$d")
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
gdb=$d/sl/slpp_all/surelog.uhdm
if [ ! -f "$gdb" ]; then
  ( cd "$d" && "$SURELOG" -parse top.sv -mt 0 -mp 0 -o "$d/sl" >"$d/sl.log" 2>&1 </dev/null )
  grc=$?
else grc=cached; fi
if [ ! -f "$gdb" ]; then echo "$n NODB grc=$grc"; exit 0; fi
( cd "$d" && "$BIN" top.sv -o "$d/ours_$TAG.uhdm" >"$d/sg_$TAG.log" 2>&1 </dev/null )
src=$?
if [ ! -f "$d/ours_$TAG.uhdm" ]; then echo "$n NOSLANG rc=$src grc=$grc"; exit 0; fi
if [ ! -f "$O/$n.gold.dump" ]; then
  "$DUMP" "$gdb" 2>/dev/null | sed "s#$d#<D>#g" > "$O/$n.gold.dump"
fi
"$DUMP" "$d/ours_$TAG.uhdm" 2>/dev/null | sed "s#$d#<D>#g" > "$O/$n.$TAG.dump"
"$CMP" "$gdb" "$d/ours_$TAG.uhdm" > "$O/$n.$TAG.cmp" 2> "$O/$n.$TAG.head"
crc=$?
eq=NE
grep -q "Design comparison: EQUAL\|EQUAL" "$O/$n.$TAG.cmp" 2>/dev/null && eq=$(tail -1 "$O/$n.$TAG.cmp" | tr -d '\r')
heads=$(grep -c '^LHS:' "$O/$n.$TAG.head" 2>/dev/null; true)
lines=$(wc -l < "$O/$n.$TAG.cmp")
echo "$n OK rc=$src grc=$grc crc=$crc heads=$heads cmplines=$lines"
