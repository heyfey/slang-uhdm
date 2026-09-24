#!/usr/bin/env bash
# r11v11u118 verifier arm driver.  usage: varm.sh <arm dir> <outdir> <pristine bin> <law bin>
# Goldens: g187 (pinned v1.87, probe flags) and gds (uhdm2rtlil's own Surelog, downstream flags).
# Per binary tag P/L: ours_T.uhdm (probe flags), ours_ds_T.uhdm (-DSYNTHESIS); uhdm-cmp line count
# vs g187; downstream verdict (ds.one); field lines (const printer, ids stripped) vs gds, and
# order-blind uhdm-dump lines vs gds.  AWAY = mismatch lines the law build has that pristine lacks.
set -u
A=$(cd "$1" && pwd); O=$2; BP=$3; BL=$4
REPO=${REPO:-/tmp/wt_v11u118}; C=${CONST:-/tmp/v11u118_const}
U2RSL=$UHDM2RTLIL_ROOT/build/third_party/Surelog/bin/surelog
rm -rf "$O"; mkdir -p "$O"/g187 "$O"/gds
(cd "$A" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$O"/g187 >"$O"/g187.log 2>&1); r1=$?
(cd "$A" && $U2RSL -parse -nobuiltin -nocache -DSYNTHESIS -filterprotected -d vpi_ids -d uhdm -sv dut.sv -mt 0 -mp 0 -o "$O"/gds >"$O"/gds.log 2>&1); r2=$?
cp "$(find "$O"/g187 -name surelog.uhdm | head -1)" "$O"/g187.uhdm 2>/dev/null
cp "$(find "$O"/gds -name surelog.uhdm | head -1)" "$O"/gds.uhdm 2>/dev/null
norm(){ sed -E 's/#[0-9]+//g; s/\|[^ ]*\/dut\.sv/|dut.sv/g' | sort; }
$C "$O"/gds.uhdm 2>/dev/null | norm > "$O"/f_gds.txt
$UHDM_DUMP "$O"/gds.uhdm 2>/dev/null | sed -E "s#$A/##g; s#$O/##g; s#^(gds|ours_ds_[PL])\.uhdm: Restored#DB: Restored#" | sort > "$O"/d_gds.txt
line="ARM $(basename $A) rc_g=$r1/$r2"
for T in P L; do
  B=$BP; [ $T = L ] && B=$BL
  (cd "$A" && $B dut.sv --single-unit --nobuiltin -o "$O"/ours_$T.uhdm >"$O"/ours_$T.log 2>&1); r3=$?
  (cd "$A" && $B -DSYNTHESIS dut.sv --single-unit --nobuiltin -o "$O"/ours_ds_$T.uhdm >"$O"/ours_ds_$T.log 2>&1); r4=$?
  n=$($UHDM_CMP "$O"/g187.uhdm "$O"/ours_$T.uhdm 2>&1 | wc -l)
  v=$(cd "$REPO" && SLANG_UHDM=$B python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('arm', '$A', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$O/ds_$T', 300); print(r['verdict']+'/'+r['differs'].replace(' ','+'))" 2>&1 | tail -1)
  $C "$O"/ours_ds_$T.uhdm 2>/dev/null | norm > "$O"/f_$T.txt
  $UHDM_DUMP "$O"/ours_ds_$T.uhdm 2>/dev/null | sed -E "s#$A/##g; s#$O/##g; s#^(gds|ours_ds_[PL])\.uhdm: Restored#DB: Restored#" | sort > "$O"/d_$T.txt
  # mismatch sets (multiset-aware: comm on sorted with duplicates)
  comm -3 "$O"/f_gds.txt "$O"/f_$T.txt > "$O"/fm_$T.txt
  comm -3 "$O"/d_gds.txt "$O"/d_$T.txt > "$O"/dm_$T.txt
  line="$line | $T rc=$r3/$r4 cmp=$n ds=$v fmis=$(wc -l < "$O"/fm_$T.txt) dmis=$(wc -l < "$O"/dm_$T.txt)"
done
fa=$(comm -13 <(sort "$O"/fm_P.txt) <(sort "$O"/fm_L.txt) | wc -l)
da=$(comm -13 <(sort "$O"/dm_P.txt) <(sort "$O"/dm_L.txt) | wc -l)
same=$(cmp -s "$O"/ours_P.uhdm "$O"/ours_L.uhdm && echo SAMEBYTES || echo MOVED)
echo "$line | FAWAY=$fa DAWAY=$da $same"
