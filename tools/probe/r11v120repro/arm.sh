#!/usr/bin/env bash
# v11u120 arm driver: arm.sh <arm dir> <outdir>
# g187 = pinned Surelog v1.87 probe flags; ours{L,P} = law/pristine binary probe flags
# ds{L,P} = downstream verdict (law harness+law bin / pristine harness+pristine bin)
set -u
source /tmp/v11u120_env.sh
A=$(cd "$1" && pwd); O=$2
LAW=${LAW:-/tmp/v11u120_bin/law.bin}; PRI=/tmp/v11u120_bin/pri.bin
rm -rf "$O"; mkdir -p "$O"/g187
(cd "$A" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$O"/g187 >"$O"/g187.log 2>&1); r1=$?
(cd "$A" && $LAW dut.sv --single-unit --nobuiltin -o "$O"/oursL.uhdm >"$O"/oursL.log 2>&1); r2=$?
(cd "$A" && $PRI dut.sv --single-unit --nobuiltin -o "$O"/oursP.uhdm >"$O"/oursP.log 2>&1); r3=$?
G=$(find "$O"/g187 -name surelog.uhdm | head -1); cp "$G" "$O"/g187.uhdm 2>/dev/null
cL=$($UHDM_CMP "$O"/g187.uhdm "$O"/oursL.uhdm 2>&1 | wc -l)
cP=$($UHDM_CMP "$O"/g187.uhdm "$O"/oursP.uhdm 2>&1 | wc -l)
h=$(echo "$A" | md5sum | cut -c1-14)
vL=$(cd /tmp/wt_v11u120 && SLANG_UHDM=$LAW python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('vL$h', '$A', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$O/dsL', 300); print(r['verdict']+':'+r['differs'].replace(' ','+'))" 2>&1 | tail -1)
vP=$(cd /tmp/wt_v11u120pris && SLANG_UHDM=$PRI python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('vP$h', '$A', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$O/dsP', 300); print(r['verdict']+':'+r['differs'].replace(' ','+'))" 2>&1 | tail -1)
sm=same; cmp -s "$O"/oursL.uhdm "$O"/oursP.uhdm || sm=MOVED
echo "ARM $(basename $A) rc=$r1/$r2/$r3 cmpP=$cP cmpL=$cL dsP=$vP dsL=$vL bytes=$sm"
