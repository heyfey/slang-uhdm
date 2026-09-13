#!/usr/bin/env bash
# r11u17 GATES transcript.  Run from the worktree once every sweep has landed.
set -u
W=/tmp/r11u17_wd
P=/home/heyfey/git-repos/slang-uhdm/tools/probe
R=$(pwd)
echo "===== 1. BINARIES"
md5sum /tmp/r11u17_bin/pris.bin /tmp/r11u17_bin/law.bin
echo "the OPS-stated main-tree md5 at the base 76c8a58b: 5bbb42c0fbc7e2c76e95e6f70464d0ae"
echo "  -> the pristine binary REPRODUCES it exactly.  (The main tree's own"
echo "     build/slang-uhdm is NOT a valid comparand any more: the master"
echo "     rebuilt it while integrating the next pass.  Its md5 now:)"
md5sum /home/heyfey/git-repos/slang-uhdm/build/slang-uhdm
echo
echo "===== 1b. cmds.txt BINARY AUDIT (every arm, by PATH)"
for wd in $W/pris_sl $W/law_sl $W/pris_u2r $W/law_u2r; do
  echo "-- $wd"
  find $wd -name cmds.txt -exec grep -ho '/tmp/r11u17_bin/[a-z]*\.bin' {} + | sort | uniq -c
done
echo
echo "===== 2. GOLDEN TESTS"
echo "law:      PASS=$(grep -c '^PASS' /tmp/r11u17_goldens_law.txt; true) FAIL=$(grep -c '^FAIL' /tmp/r11u17_goldens_law.txt; true)"
echo "/bin/false: PASS=$(grep -c '^PASS' /tmp/r11u17_goldens_neg.txt; true) FAIL=$(grep -c '^FAIL' /tmp/r11u17_goldens_neg.txt; true)"
echo
echo "===== 3. uhdm2rtlil, BOTH MODES"
for m in tf def; do
  for b in pris law; do
    f=$W/${b}_u2r_${m}.csv
    echo "$b/$m: EQUAL=$(grep -c CMP_EQUAL $f; true) NOTEQUAL=$(grep -c CMP_NOTEQUAL $f; true) REJECT=$(grep -c SLANG_REJECT $f; true)"
  done
done
echo "-- ct8rows law/testflags vs the COMMITTED baseline results/gate_uhdm2rtlil.csv"
bash $P/r10oth8repro/ct8rows.sh $R/results/gate_uhdm2rtlil.csv $W/law_u2r_tf.csv | tail -n 20
echo "-- ct8rows law/default vs the COMMITTED baseline results/golden_uhdm2rtlil.csv (default half)"
python3 - <<'PY'
import csv,sys
rows=[r for r in csv.reader(open('/home/heyfey/git-repos/slang-uhdm/results/golden_uhdm2rtlil.csv')) ]
hdr=rows[0]
out=[hdr]+[r for r in rows[1:] if r[1]=='default']
import io
w=csv.writer(open('/tmp/r11u17_base_u2r_def.csv','w'),lineterminator='\n'); w.writerows(out)
print("base default rows:",len(out)-1)
PY
bash $P/r10oth8repro/ct8rows.sh /tmp/r11u17_base_u2r_def.csv $W/law_u2r_def.csv | tail -n 20
echo "-- ct8rows PRISTINE/testflags vs the committed baseline (the control: my own pristine reproduces the base)"
bash $P/r10oth8repro/ct8rows.sh $R/results/gate_uhdm2rtlil.csv $W/pris_u2r_tf.csv | tail -n 6
echo
echo "===== 4. surelog, --mode both"
for b in pris law; do
  f=$W/${b}_sl.csv
  echo "$b default : EQUAL=$(awk -F, '$2=="default"' $f | grep -c CMP_EQUAL; true) NOTEQUAL=$(awk -F, '$2=="default"' $f | grep -c CMP_NOTEQUAL; true)"
  echo "$b testflags: EQUAL=$(awk -F, '$2=="testflags"' $f | grep -c CMP_EQUAL; true) NOTEQUAL=$(awk -F, '$2=="testflags"' $f | grep -c CMP_NOTEQUAL; true)"
done
echo "-- ct8rows law vs the COMMITTED baseline results/golden_surelog.csv"
bash $P/r10oth8repro/ct8rows.sh $R/results/golden_surelog.csv $W/law_sl.csv | tail -n 20
echo "-- ct8rows law vs MY OWN PRISTINE sweep (the real boundary: same harness, same goldens)"
bash $P/r10oth8repro/ct8rows.sh $W/pris_sl.csv $W/law_sl.csv | tail -n 20
echo
echo "===== 5. BYTEVERIFY (SELFCHECK=1) against my own pristine workdirs"
echo "-- u2r"; SELFCHECK=1 bash $P/r10oth4repro/byteverify.sh $W/law_u2r $W/pris_u2r | grep -E 'MOVER|SELFCHECK|PATH|databases|movers'
echo "-- surelog"; SELFCHECK=1 bash $P/r10oth4repro/byteverify.sh $W/law_sl $W/pris_sl | grep -E 'MOVER|SELFCHECK|PATH|databases|movers'
echo
echo "===== 6. CANARIES"
bash $P/r10uvm52repro/canaries.sh $W/law_sl.csv $R/results/golden_surelog.csv | grep 'ok='
bash $P/r10uvm52repro/canaries.sh $W/law_u2r_tf.csv $R/results/gate_uhdm2rtlil.csv | grep 'ok='
EXPECT_UNKNOWN=1 bash $P/r10uvm67repro/ctcan2.sh $R/results/golden_surelog.csv $W/law_sl.csv | tail -n 1
EXPECT_UNKNOWN=6 bash $P/r10uvm67repro/ctcan2.sh $R/results/gate_uhdm2rtlil.csv $W/law_u2r_tf.csv | tail -n 1
(cd $R/tools/probe/r11u17repro && bash canaudit.sh canaries.sh ctcan2.sh | tail -n 1)
echo
echo "===== 7. PROTECTED DATABASES BY NAME (md5, law vs pristine)"
for n in InterfaceModPort BlackParrotComplex YosysOldOr SVSwitch YosysVerx; do
  for m in default testflags; do
    a=$(find $W/law_sl/$m -maxdepth 1 -name "$n-*" -type d | head -1)
    b=$(find $W/pris_sl/$m -maxdepth 1 -name "$n-*" -type d | head -1)
    [ -n "$a" ] && [ -f "$a/slang.uhdm" ] || continue
    ma=$(md5sum $a/slang.uhdm | cut -c1-12); mb=$(md5sum $b/slang.uhdm | cut -c1-12)
    s=SAME; [ "$ma" != "$mb" ] && s=MOVED
    echo "$n/$m law=$ma pristine=$mb $s"
  done
done
echo
echo "===== 8. BOUNDARY over the landed passes' arms"
OUT=/tmp/r11u17_bndG bash $R/tools/probe/r11u17repro/bnd.sh $R/tools/probe/r11u17repro/BND.list.txt | grep -v 'norm_delta=0'
echo
echo "===== 9. GRID (41 arms, both tags)"
cat /tmp/r11u17_GRID.txt
