#!/usr/bin/env bash
# r11u118 arm driver.  usage: arm.sh <arm dir with dut.sv> <outdir> [binary]
# Builds: g187.uhdm (pinned Surelog v1.87, probe flags), gds.uhdm (uhdm2rtlil's
# own Surelog, downstream flags), ours.uhdm (binary, probe flags), ours_ds.uhdm
# (binary, -DSYNTHESIS).  Prints rc of each, the uhdm-cmp line count
# (g187 vs ours) and the downstream verdict (scripts/downstream_uhdm2rtlil.one).
set -u
A=$(cd "$1" && pwd); O=$2; B=${3:-$SLANG_UHDM}
REPO=${REPO:-/tmp/wt_r11u118}
U2RSL=${UHDM2RTLIL_ROOT:-/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil}/build/third_party/Surelog/bin/surelog
# the writer does not truncate an existing file: remove every output first
mkdir -p "$O"; rm -rf "$O"/g187 "$O"/gds "$O"/ds "$O"/*.uhdm; mkdir -p "$O"/g187 "$O"/gds
(cd "$A" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$O"/g187 >"$O"/g187.log 2>&1); r1=$?
(cd "$A" && $U2RSL -parse -nobuiltin -nocache -DSYNTHESIS -filterprotected -d vpi_ids -d uhdm -sv dut.sv -mt 0 -mp 0 -o "$O"/gds >"$O"/gds.log 2>&1); r2=$?
(cd "$A" && $B dut.sv --single-unit --nobuiltin -o "$O"/ours.uhdm >"$O"/ours.log 2>&1); r3=$?
(cd "$A" && $B -DSYNTHESIS dut.sv --single-unit --nobuiltin -o "$O"/ours_ds.uhdm >"$O"/ours_ds.log 2>&1); r4=$?
G187=$(find "$O"/g187 -name surelog.uhdm | head -1); GDS=$(find "$O"/gds -name surelog.uhdm | head -1)
cp "$G187" "$O"/g187.uhdm 2>/dev/null; cp "$GDS" "$O"/gds.uhdm 2>/dev/null
n=$($UHDM_CMP "$O"/g187.uhdm "$O"/ours.uhdm 2>&1 | wc -l)
v=$(cd "$REPO" && SLANG_UHDM=$B python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('arm', '$A', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$O/ds', 300); print(r['verdict'], r['differs'])" 2>&1 | tail -1)
echo "ARM $(basename $A) rc=$r1/$r2/$r3/$r4 cmp=$n ds=$v"
