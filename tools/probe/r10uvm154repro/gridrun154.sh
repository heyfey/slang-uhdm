#!/usr/bin/env bash
# r10uvm154 — run ONE grid cell: Surelog (LHS, always golden) and ours (RHS),
# each into its own scratch, and leave the two path-normalisable dumps behind
# for score154.py.  MEASUREMENT ONLY.
#
#   SLANG_UHDM=/abs/path/to/binary gridrun154.sh <src.sv> <workroot>
#
# Surelog synthesizes builtin.sv AS A FILE IN THE CWD, so every cell runs in its
# own directory and both tools see identical paths.
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/.local/bin/uhdm-dump
SRC=$1; WR=$2
B=$(basename "$SRC" .sv)
D=$WR/$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$B.sv" >surelog.log 2>&1
if [ -f slpp_all/surelog.uhdm ]; then
  "$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
else echo "GOLDEN_FAIL $B"; fi
"$SLANG_UHDM" "$B.sv" -o slang.uhdm >slang.log 2>&1
rc=$?
if [ -f slang.uhdm ]; then
  "$DUMP" slang.uhdm 2>/dev/null | sed 1d > o.dump
else echo "SLANG_REJECT $B rc=$rc"; fi
