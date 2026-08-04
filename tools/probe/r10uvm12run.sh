#!/bin/bash
# r10uvm12run.sh — purpose-built pair runner for the UVM-4 dropped-construct
# decode.  Usage: r10uvm12run.sh <dir-with-t.sv> [tag]
# Emits def (no -elabuhdm) and elab views for BOTH tools into <dir>/ and diffs
# the uhdm-dump texts.
set -u
D=$(cd "$1" && pwd)
TAG=${2:-t}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
SU=${SLANG_UHDM:?set SLANG_UHDM}
cd "$D" || exit 1
rm -rf slpp_all slpp_unit gd ge
# golden def
$SL -parse -sverilog -d 0 -mt 0 -mp 0 -nocache t.sv >gd.log 2>&1
mv slpp_all/surelog.uhdm gd.uhdm 2>/dev/null
rm -rf slpp_all
# golden elab
$SL -parse -elabuhdm -sverilog -d 0 -mt 0 -mp 0 -nocache t.sv >ge.log 2>&1
mv slpp_all/surelog.uhdm ge.uhdm 2>/dev/null
rm -rf slpp_all
# ours
$SU t.sv --single-unit -o sd.uhdm >sd.log 2>&1
$SU t.sv --single-unit --elabuhdm -o se.uhdm >se.log 2>&1
for v in gd ge sd se; do
  [ -f $v.uhdm ] && $DUMP $v.uhdm > $v.txt 2>/dev/null
done
echo "--- def diff (golden vs ours) ---"
diff gd.txt sd.txt | head -${HEAD:-80}
echo "--- def diff lines: $(diff gd.txt sd.txt | wc -l)"
echo "--- elab diff lines: $(diff ge.txt se.txt | wc -l)"
