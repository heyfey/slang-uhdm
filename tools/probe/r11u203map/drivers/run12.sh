#!/bin/bash
# The r11u203 map pipeline (twelfth edition, measurement only), as run. No source edit anywhere: the pristine binary
# is the worktree build of ddc67d87 (= the main tree's build/slang-uhdm, md5 18183f058868); the r11u200 binary is
# ddc67d87 + evidence/law200_on_ddc67d87.patch (r11u200's law_exprstmt.patch, clean over pass 198, + law_typeemit.patch
# rebased over pass 196: two conflicts, its class-in-module listing and typespec half, which duplicate pass 196's landed
# § modGenericClassListed196 / § modGenericHandleBare196; pass 196's versions kept) built in the scratch worktree
# /tmp/wt_r11u203L, MEASUREMENT ONLY; lawA / lawB are the two ground halves alone (incremental rebuilds of the same
# scratch worktree). Every driver that reads a database or a source refuses the four slang-fenced names
# (common.fenced(): the FENCED= line of tools/probe/r11u107repro/canaudit.sh; fail closed).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results; E=$DR/../evidence
. "$DR/env.sh"          # pins, B=/tmp/r11u203_bin, W=/tmp/r11u203_W, H=/tmp/intr11u196, FENCED
# 0. binaries frozen chmod 555 in $B: slang-uhdm (18183f05), uhdm-strictcmp (fa6e4f42), strictcmp_x (drivers/cc.sh,
#    5bbd7f83 = map 11's), objrank, slang-uhdm.law200 (8c135e66), slang-uhdm.lawA (ce1ab244), slang-uhdm.lawB (281fae81),
#    slang-uhdm.g1 (worktree /tmp/wt_r11u203g, -DCMAKE_CXX_FLAGS=-g1, target slang_uhdm; gdb pins only, d10de76a)
# 1. jobs + strict runs over the HEAD sweep: every STRICT_NOTEQUAL row-mode (50) and every probe case (4087)
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
# 2. ids (map 11's persist; keys new under the law patches from N2467, report12.py)
python3 "$DR/final12.py" "$W" "$REPO" "$W/out" $H > final12.txt
# 3. the firing census (the mover PREDICTION, frozen chmod 444 before the law sweep), then the law gate sweep
#    (/tmp/r11u203_s/lawsweep.sh as run: census.sh with R11U200_TRACE, censum.py, chmod 444, tests/sweep.sh --jobs 3)
SLANG_UHDM=$B/slang-uhdm.law200 bash "$DR/census.sh" /tmp/r11u203_cen/wd /tmp/r11u203_cen/trace /tmp/r11u203_cen/census
( cd "$REPO" && python3 "$DR/censum.py" /tmp/r11u203_cen/trace /tmp/r11u203_cen/wd ) > /tmp/r11u203_cen/census_law.txt
chmod 444 /tmp/r11u203_cen/census_law.txt
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm.law200 tests/sweep.sh --jobs 3 --workdir /tmp/r11u203_sL ) > /tmp/r11u203_sL.log 2>&1 || true
# 4. the r11u200 cross-section MEASURED (the law sweep's STRICT_NOTEQUAL rows and cases re-dumped and re-keyed: WS)
bash "$DR/crosssection.sh"
# 5. pins: one gdb run per example row for the clusters whose example object changed since map 11 (ignoring record
#    indices; >= 3 row-modes, a first record, or >= 40 cases), minus the coin-only UVM ones (pinwant.txt: 5 clusters)
PART=0/1 python3 "$DR/pinmulti.py" "$W" /home/heyfey/git-repos/slang-uhdm "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp0" "$W/pins_new0.txt" $(cat $W/pinwant.txt)
cp $W/pins_new0.txt $W/pins_final.txt
python3 "$DR/sites.py" $W/pins_final.txt $W/sites_new.json /tmp/wt_r11u203g/src
python3 "$DR/mksites12.py" $W/pins_final.txt $W/sites_new.json "$REPO/tools/probe/r11u197map" $W/sites.json
#    (+ the two keys new under the patches, N2467 / N2468, sited by their switch attribution: evidence/away/)
# 6. tables, audit, evidence
python3 "$DR/report12.py" "$W" /tmp/r11u203_WS "$W/out" /tmp/r11u203_sL "$E/routes.json" "$E/ground_override.json" "$REPO" > $W/report.txt
( cd "$REPO" && python3 "$DR/audit12.py" "$REPO" "$W/out" ) > $W/audit.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat $W/evwant.txt)
for t in t1 nonfam newc fail pfirst; do python3 "$DR/tables12.py" "$W/out" $t 30 > $W/t_$t.md; done
# 7. byte movers (fence-free hard-link mirrors), per-patch attribution, the AWAY census and its switch attribution,
#    the UVM census and distance, the downstream faces, the determinism control, the positive controls
bash "$DR/bvmirror.sh" $H /tmp/r11u203_bvH; bash "$DR/bvmirror.sh" /tmp/r11u203_sL /tmp/r11u203_bvL
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" /tmp/r11u203_bvL /tmp/r11u203_bvH
bash "$DR/attribution.sh"
( cd /tmp/r11u203_WS && python3 "$DR/awaycensus.py" $W/dumps /tmp/r11u203_WS/dumps jobs_int.tsv; python3 "$DR/awaycensus.py" $W/pdumps /tmp/r11u203_WS/pdumps probe_ne.tsv )
bash "$DR/sw.sh"
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm; bash "$DR/uvmcensus9.sh" /tmp/r11u203_WS/corpus.jsonl /tmp/r11u203_WS/uvm
UVMDIST_TESTS="MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg SVSwitch Earlgrey_0_1 Rggen Scr1SvTests UnitElabBlock BlackBePipeInt" UVMDIST_TMP=/tmp/r11u203_uvmdist bash "$DR/uvmdist.sh" $H /tmp/r11u203_sL
GOLDEN_CACHE=/tmp/r11u203_dsgold SLANG_UHDM=$B/slang-uhdm python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u203_dsP /tmp/r11u203_s/dsfaces_P.csv $(cat /tmp/r11u203_s/ds_cases.txt)
GOLDEN_CACHE=/tmp/r11u203_dsgold SLANG_UHDM=$B/slang-uhdm.law200 python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u203_dsL /tmp/r11u203_s/dsfaces_L.csv $(cat /tmp/r11u203_s/ds_cases.txt)
DETBIN=$B/slang-uhdm DETOUT=/tmp/r11u203_det/head bash "$DR/det.sh"; DETOUT=/tmp/r11u203_det/head bash "$DR/ob.sh"
# 8. the deliverable: this directory; a grep for the fenced names reads 0
