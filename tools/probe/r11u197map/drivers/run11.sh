#!/bin/bash
# The r11u197 map pipeline (eleventh edition, measurement only), as run. No source edit anywhere: the pristine binary
# is the worktree build of 4a65840e (= the main tree's build/slang-uhdm, md5 14dc35040e6a); the r11u191 binary is
# 4a65840e + evidence/law191_both_on_4a65840e.patch (r11u191's law_exprstmt.patch rebased over passes 192 and 194, one
# conflict at the top of emitExpr resolved with pass 194's lhsGuard194 first, + law_typeemit.patch, clean with offsets)
# built in the scratch worktree /tmp/wt_r11u197L, MEASUREMENT ONLY; lawA / lawB are the two patches alone (incremental
# rebuilds of the same scratch worktree, the other ground's files restored). Every driver that reads a database or a
# source refuses the four slang-fenced names (common.fenced(): the FENCED= line of tools/probe/r11u107repro/canaudit.sh;
# fail closed).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results
. "$DR/env.sh"          # pins, B=/tmp/r11u197_bin, W=/tmp/r11u197_W, H=/tmp/intr11u194, FENCED
WS=/tmp/r11u197_WS
# 0. binaries frozen chmod 555 in $B: slang-uhdm (14dc3504), uhdm-strictcmp (fa6e4f42), strictcmp_x (drivers/cc.sh,
#    5bbd7f83), objrank (3e213a15), slang-uhdm.law191 (a26ee82b), slang-uhdm.g1 (-DCMAKE_CXX_FLAGS=-g1, gdb only,
#    cb1b8546), slang-uhdm.lawA (5e85033f), slang-uhdm.lawB (9a6c3283)
# 1. jobs + strict runs over the HEAD sweep: every STRICT_NOTEQUAL row-mode (60) and every probe case (4087)
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
# 2. ids (map 10's persist; new from N2464)
python3 "$DR/final11.py" "$W" "$REPO" "$W/out" $H > final11.txt
# 3. the firing census (the mover PREDICTION, frozen chmod 444 before the law sweep), then the law gate sweep
SLANG_UHDM=$B/slang-uhdm.law191 bash "$DR/census.sh" /tmp/r11u197_cen/wd /tmp/r11u197_cen/trace /tmp/r11u197_cen/census
( cd "$REPO" && python3 "$DR/censum.py" /tmp/r11u197_cen/trace /tmp/r11u197_cen/wd ) > /tmp/r11u197_cen/census_law.txt
chmod 444 /tmp/r11u197_cen/census_law.txt
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm.law191 tests/sweep.sh --jobs 3 --workdir /tmp/r11u197_sL ) > /tmp/r11u197_sL.log 2>&1 || true
# 4. pins: one gdb run per example row (pinwant.txt: new clusters, no-pin clusters, and big clusters whose example
#    changed ignoring record indices, minus the coin-only UVM ones); the probe cwd is the MAIN tree's tests/probe case
#    dir (the database embeds the absolute source path)
PART=0/1 python3 "$DR/pinmulti.py" "$W" /home/heyfey/git-repos/slang-uhdm "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp0" "$W/pins_new0.txt" $(cat pinwant.txt)
cp pins_new0.txt pins_final.txt
python3 "$DR/sites.py" pins_final.txt sites_new.json "$REPO/src"
python3 "$DR/mksites11.py" pins_final.txt sites_new.json "$REPO/tools/probe/r11u189map" sites.json
# 5. the r11u191 cross-section MEASURED (the law sweep's STRICT_NOTEQUAL rows re-dumped and re-keyed)
bash "$DR/crosssection.sh"
# 6. tables, audit, evidence
python3 "$DR/report11.py" "$W" "$WS" "$W/out" /tmp/r11u197_sL "$DR/../evidence/routes.json" "$DR/../evidence/ground_override.json" "$REPO" > report.txt
( cd "$REPO" && python3 "$DR/audit11.py" "$REPO" "$W/out" ) > audit.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat evwant.txt)
for t in t1 nonfam pfirst fail newc; do python3 "$DR/tables11.py" "$W/out" $t 30 > t_$t.md; done
# 7. byte movers (fence-free hard-link mirrors), canaries, per-patch attribution, the UVM census and distance, the
#    downstream faces, the determinism control
bash "$DR/bvmirror.sh" $H /tmp/r11u197_bvH; bash "$DR/bvmirror.sh" /tmp/r11u197_sL /tmp/r11u197_bvL
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" /tmp/r11u197_bvL /tmp/r11u197_bvH
bash "$DR/attribution.sh"
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm; bash "$DR/uvmcensus9.sh" $WS/corpus.jsonl $WS/uvm
bash "$DR/uvmdist.sh" $H; bash "$DR/uvmdist.sh" /tmp/r11u197_sL
GOLDEN_CACHE=/tmp/r11u197_dsgold SLANG_UHDM=$B/slang-uhdm python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u197_dsP /tmp/r11u197_dsfaces_P.csv $(cat /tmp/r11u197_dscases/list.txt)
GOLDEN_CACHE=/tmp/r11u197_dsgold SLANG_UHDM=$B/slang-uhdm.law191 python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u197_dsL /tmp/r11u197_dsfaces_L.csv $(cat /tmp/r11u197_dscases/list.txt)
DETBIN=$B/slang-uhdm DETOUT=/tmp/r11u197_det/head bash "$DR/det.sh"; DETOUT=/tmp/r11u197_det/head bash "$DR/ob.sh"
DETBIN=$B/slang-uhdm.law191 DETOUT=/tmp/r11u197_det/law bash "$DR/det.sh"; DETOUT=/tmp/r11u197_det/law DETHEAD=0 bash "$DR/ob.sh"
# 8. the deliverable: this directory; a grep for the fenced names reads 0
