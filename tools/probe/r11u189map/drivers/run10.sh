#!/bin/bash
# The r11u189 map pipeline (tenth edition, measurement only), as run. No source edit anywhere: the pristine binary is
# the worktree build of 2b97649e (= the main tree's build/slang-uhdm, md5 78e0b9590a16); the r11u183 binary is
# 2b97649e + evidence/law183_scratch_2b97649e.patch (= r11u183's law_exprstmt.patch, clean, + law_typeemit.patch rebased
# over passes 176 and 180: r11u183's 804e3b75 rebase applied with one UhdmExporter hunk re-inserted by hand after pass
# 180's noteTpUse180 call) built in the scratch worktree /tmp/wt_r11u189L, MEASUREMENT ONLY; lawA / lawB are the two
# patches alone (/tmp/wt_r11u189A, /tmp/wt_r11u189B). Every driver that reads a database or a source refuses the four
# slang-fenced names (common.fenced(): the FENCED= line of tools/probe/r11u107repro/canaudit.sh; fail closed).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results
. "$DR/env.sh"          # pins, B=/tmp/r11u189_bin, W=/tmp/r11u189_W, FENCED
H=/tmp/intr11u185       # the HEAD sweep of 2b97649e (read-only; equal to results/golden_*.csv cell for cell)
WS=/tmp/r11u189_WS
# 0. binaries frozen chmod 555 in $B: slang-uhdm (78e0b959), uhdm-strictcmp (5d4617d0), strictcmp_x (drivers/cc.sh,
#    db96066a), objrank, slang-uhdm.law183 (f2b351c4), slang-uhdm.g1 (-DCMAKE_CXX_FLAGS=-g1, gdb only),
#    slang-uhdm.lawA (f5b8884f), slang-uhdm.lawB (ce82cc50)
# 1. jobs + strict runs over the HEAD sweep: every STRICT_NOTEQUAL row-mode (84) and every probe case (4087)
mkdir -p $W; cd $W
python3 "$DR/jobs.py" "$RES/golden_surelog.csv" "$RES/golden_uhdm2rtlil.csv" $H jobs_int.tsv
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" $H/probe "$W/probejobs.tsv" )
( cd "$REPO" && python3 "$DR/probelaw.py" ) | grep -P '\t' > probe_law.tsv
bash "$DR/strict_runs.sh"
: > probe_ne.tsv; : > probe_verdict.tsv
while IFS=$'\t' read c m n g o rel; do f=$W/pdumps/probe/default/$n.out
  if grep -q '^rc=2' "$f"; then printf '%s\t%s\t%s\t%s\t%s\t%s\n' $c $m $n $g $o $rel >> probe_ne.tsv
    printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $f | cut -d' ' -f2)" >> probe_verdict.tsv; fi
done < probejobs.tsv
cp $H/surelog.csv sweep_surelog.csv; cp $H/uhdm2rtlil.csv sweep_uhdm2rtlil.csv; cp $H/probe.csv sweep_probe.csv
R11U138_TMP=$W/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 3
R11U138_TMP=$W/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
# 2. ids (map 9's persist; new from N2416)
python3 "$DR/final10.py" "$W" "$REPO" "$W/out" $H > final10.txt
# 3. the firing census (the mover PREDICTION, frozen chmod 444 before the law sweep), then the law gate sweep
SLANG_UHDM=$B/slang-uhdm.law183 bash "$DR/census.sh" /tmp/r11u189_cen/wd /tmp/r11u189_cen/trace /tmp/r11u189_cen/census
( cd "$REPO" && python3 "$DR/censum.py" /tmp/r11u189_cen/trace /tmp/r11u189_cen/wd ) > /tmp/r11u189_cen/census_law.txt
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm.law183 tests/sweep.sh --jobs 3 --workdir /tmp/r11u189_sL ) > /tmp/r11u189_sL.log 2>&1 || true
# 4. pins: one gdb run per example row (pinwant.txt); the probe cwd is the MAIN tree's tests/probe case dir because the
#    database embeds the absolute source path (a worktree cwd wrote 99 of 100 databases differently: db=DIFF)
PART=0/1 python3 "$DR/pinmulti.py" "$W" /home/heyfey/git-repos/slang-uhdm "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp0" "$W/pins_new0.txt" $(cat pinwant.txt)
cp pins_new0.txt pins_final.txt
python3 "$DR/sites.py" pins_final.txt sites_new.json "$REPO/src"
python3 "$DR/mksites10.py" pins_final.txt sites_new.json "$REPO/tools/probe/r11u179map" sites.json
# 5. the r11u183 cross-section MEASURED (the law sweep's STRICT_NOTEQUAL rows re-dumped and re-keyed)
bash "$DR/crosssection.sh"
# 6. tables, audit, evidence
python3 "$DR/report10.py" "$W" "$WS" "$W/out" /tmp/r11u189_sL "$DR/../evidence/routes.json" "$DR/../evidence/ground_override.json" "$REPO" > report.txt
( cd "$REPO" && python3 "$DR/audit10.py" "$REPO" "$W/out" ) > audit.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat evwant.txt)
# 7. byte movers (fence-free hard-link mirrors), canaries, per-patch attribution, the UVM census and distance, the
#    downstream faces, the determinism control
bash "$DR/bvmirror.sh" $H /tmp/r11u189_bvH; bash "$DR/bvmirror.sh" /tmp/r11u189_sL /tmp/r11u189_bvL
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" /tmp/r11u189_bvL /tmp/r11u189_bvH
bash "$DR/buildAB.sh"; bash "$DR/attribution.sh"
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm; bash "$DR/uvmcensus9.sh" $WS/corpus.jsonl $WS/uvm
bash "$DR/uvmdist.sh" $H /tmp/r11u189_sL > /tmp/r11u189_uvmdist.txt
GOLDEN_CACHE=/tmp/r11u189_dsgold SLANG_UHDM=$B/slang-uhdm python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u189_dsP /tmp/r11u189_dsfaces_P.csv $(cat /tmp/r11u189_dscases/list.txt) /tmp/r11u189_dscases/LT/l01 /tmp/r11u189_dscases/LT/l02
GOLDEN_CACHE=/tmp/r11u189_dsgold SLANG_UHDM=$B/slang-uhdm.law183 python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u189_dsL /tmp/r11u189_dsfaces_L.csv $(cat /tmp/r11u189_dscases/list.txt) /tmp/r11u189_dscases/LT/l01 /tmp/r11u189_dscases/LT/l02
bash "$DR/det.sh"; bash "$DR/ob.sh"
# 8. the deliverable: this directory; a grep for the fenced names reads 0
