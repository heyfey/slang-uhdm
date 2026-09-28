#!/bin/bash
# The r11u211 map pipeline (thirteenth edition, measurement only), as run. No source edit anywhere: the pristine
# binary is the worktree build of 4acbe8a5 (= the main tree's build/slang-uhdm, md5 9c0e77451011); the r11u205 binaries
# are 4acbe8a5 + evidence/law205_on_4acbe8a5.patch (r11u205's law_exprstmt.patch, clean, + law_typeemit.patch minus its
# superseded first law tpDefaultUseCastAndArrayElem205, rebased over pass 206: one conflict at the exportDesign call
# site, pass 206's form kept and genConnTrailSelChain205 called after it) and its two ground halves, incremental
# rebuilds of the scratch worktree /tmp/wt_r11u211L (MEASUREMENT ONLY). Every driver that reads a database or a source
# refuses the four slang-fenced names (common.fenced() / env.sh FENCED: the FENCED= line of
# tools/probe/r11u107repro/canaudit.sh; fail closed).
set -eu
DR=/tmp/wt_r11u211/tools/probe/r11u211map/drivers; REPO=/tmp/wt_r11u211; RES=$REPO/results; E=$DR/../evidence
. "$DR/env.sh"          # pins, B=/tmp/r11u211_bin, W=/tmp/r11u211_W, H=/tmp/intr11u208, FENCED, FENCERE
# 0. binaries frozen chmod 555 in $B: slang-uhdm (9c0e7745), slang-uhdm.rebuild2 (the second independent build of the
#    pristine source, /tmp/wt_r11u211L: 9c0e7745 too), uhdm-strictcmp (fa6e4f42), strictcmp_x (drivers/cc.sh, 5bbd7f83
#    = map 12's), objrank, slang-uhdm.law205 (e197e9c7), slang-uhdm.lawA205 (f70d2717), slang-uhdm.lawB205 (9f049970),
#    slang-uhdm.g1 (/tmp/wt_r11u211/build-g1, -DCMAKE_CXX_FLAGS=-g1, target slang_uhdm; gdb pins only, 8b6b9be5);
#    the state wrappers st4/st2/st1/st6/st8.sh (the HEAD binary under one landing's switches, section 6)
# 1. jobs + strict runs over the HEAD sweep: every STRICT_NOTEQUAL row-mode (42) and every probe case (4087)
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
# 2. ids (map 12's persist; the one new key gets N2469)
python3 "$DR/final13.py" "$W" "$REPO" "$W/out" $H > final13.txt
# 3. the pristine gate sweep (/tmp/r11u211_sP), the firing census of law205 (the mover PREDICTION, frozen chmod 444
#    before the law sweep) and law205's full gate sweep (/tmp/r11u211_sL): drivers/lawsweep.sh
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm tests/sweep.sh --jobs 3 --workdir /tmp/r11u211_sP ) > /tmp/r11u211_sP.log 2>&1 || true
bash "$DR/lawsweep.sh"
# 4. the r11u205 cross-section MEASURED (the law sweep's STRICT_NOTEQUAL rows and cases re-dumped and re-keyed: WS)
bash "$DR/crosssection.sh"
# 5. pins: one gdb run per example row for the clusters whose example object changed since map 12 (ignoring record
#    indices; >= 3 row-modes, a first record, or >= 40 cases; coin-only UVM clusters keep map 12's pin) and the new
#    N2469; REPO for the gdb runs is the MAIN tree, whose case paths the reference probe databases embed
PART=0/1 python3 "$DR/pinmulti.py" "$W" /home/heyfey/git-repos/slang-uhdm "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp0" "$W/pins_new0.txt" $(cat $W/pinwant.txt)
PART=0/1 python3 "$DR/pinmulti.py" "$W" /home/heyfey/git-repos/slang-uhdm "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp1" "$W/pins_new1.txt" N2469
cat $W/pins_new0.txt $W/pins_new1.txt > $W/pins_final.txt
python3 "$DR/sites.py" $W/pins_final.txt $W/sites_new.json $REPO/src
python3 "$DR/mksites13.py" $W/pins_final.txt $W/sites_new.json "$REPO/tools/probe/r11u203map" $W/sites.json
# 6. routes, tables, audit, evidence
python3 "$DR/mkroutes13.py" "$REPO/tools/probe/r11u203map/evidence/routes.json" "$E/routes.json"
python3 "$DR/report13.py" "$W" /tmp/r11u211_WS "$W/out" /tmp/r11u211_sL "$E/routes.json" "$E/ground_override.json" "$REPO" > $W/report.txt
( cd /home/heyfey/git-repos/slang-uhdm && python3 "$DR/audit13.py" /home/heyfey/git-repos/slang-uhdm "$W/out" ) > $W/audit.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat $W/evwant.txt)
for t in t1 nonfam fail pfirst; do python3 "$DR/tables13.py" "$W/out" $t 30 > $W/t_$t.md; done
python3 "$DR/tables13.py" "$W/out" ground 25 A > $W/t_groundA.md; python3 "$DR/tables13.py" "$W/out" ground 25 B > $W/t_groundB.md
# 7. byte movers (fence-free hard-link mirrors), per-patch attribution, the away census of every landing since map 12
#    (the HEAD binary under each landing's switches, drivers/awayrows.py chain-keyed + flat) and of the r11u205
#    patches, the UVM census and distance, the downstream faces, the determinism and rebuild-identity controls
bash "$DR/bvmirror.sh" $H /tmp/r11u211_bvH; bash "$DR/bvmirror.sh" /tmp/r11u211_sP /tmp/r11u211_bvP; bash "$DR/bvmirror.sh" /tmp/r11u211_sL /tmp/r11u211_bvL
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" /tmp/r11u211_bvP /tmp/r11u211_bvH
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" /tmp/r11u211_bvL /tmp/r11u211_bvP
bash "$DR/attribution.sh"
for s in 4 2 1 6 8; do ( cd "$REPO" && SLANG_UHDM=$B/st$s.sh tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil" --workdir /tmp/r11u211_st$s ) > /tmp/r11u211_st$s.log 2>&1 || true
  python3 "$DR/awayrows.py" /tmp/r11u211_st$s /tmp/r11u211_sP 3 > /tmp/r11u211_away/away_st${s}_vs_P.txt; done
python3 "$DR/awayrows.py" /tmp/r11u211_sP /tmp/r11u211_sL 3 > /tmp/r11u211_away/away_P_vs_law205.txt
python3 "$DR/awayrows.py" /tmp/r11u211_sP /tmp/r11u211_st2 3 > /tmp/r11u211_away/POSCTL_reverse_P_vs_st2.txt
python3 "$DR/awayrows.py" /tmp/r11u211_sP /tmp/r11u211_atA 3 > /tmp/r11u211_away/away_P_vs_lawA205.txt
python3 "$DR/awayrows.py" /tmp/r11u211_sP /tmp/r11u211_atB 3 > /tmp/r11u211_away/away_P_vs_lawB205.txt
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm; bash "$DR/uvmcensus9.sh" /tmp/r11u211_WS/corpus.jsonl /tmp/r11u211_WS/uvm
UVMDIST_TESTS="MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg Earlgrey_0_1 Rggen Scr1SvTests UnitElabBlock BlackBePipeInt InterfArrayBind" UVMDIST_TMP=/tmp/r11u211_uvmdist bash "$DR/uvmdist.sh" $H /tmp/r11u211_sL
( cd $REPO && GOLDEN_CACHE=/tmp/r11u211_dsgold SLANG_UHDM=$B/slang-uhdm python3 "$DR/dsfaces.py" $REPO /tmp/r11u211_dsP /tmp/r11u211_s/dsfaces_P.csv $(cat /tmp/r11u211_s/ds_cases.txt) )
( cd $REPO && GOLDEN_CACHE=/tmp/r11u211_dsgold SLANG_UHDM=$B/slang-uhdm.law205 python3 "$DR/dsfaces.py" $REPO /tmp/r11u211_dsL /tmp/r11u211_s/dsfaces_L.csv $(cat /tmp/r11u211_s/ds_cases.txt) )
DETBIN=$B/slang-uhdm DETOUT=/tmp/r11u211_det/head bash "$DR/det.sh"; DETOUT=/tmp/r11u211_det/head bash "$DR/ob.sh"
for b in law205 lawA205 lawB205; do DETBIN=$B/slang-uhdm.$b DETOUT=/tmp/r11u211_det/$b DETTESTS="MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg" bash "$DR/det.sh"; done
for r in 2 3 4 5 6 7; do DETBIN=$B/slang-uhdm DETOUT=/tmp/r11u211_det/buvm$r DETTESTS=BuildUVMPkg bash "$DR/det.sh"; done
for r in seqt seqt2; do DETBIN=$B/slang-uhdm DETOUT=/tmp/r11u211_det/$r DETTESTS=SeqDriver bash "$DR/det.sh"; done
BINS="slang-uhdm slang-uhdm.rebuild2 slang-uhdm.g1 slang-uhdm.law205 slang-uhdm.lawA205 slang-uhdm.lawB205" N=3 bash "$DR/rebuildid.sh" /tmp/r11u211_rb tools/probe/r11u196repro/cases/V191/qr01
OTHER=slang-uhdm.lawA205 bash "$DR/orphanscan.sh" /tmp/r11u211_orph tools/probe/r11u196repro/cases tools/probe/v11u196repro tools/probe/r11u204verify/cases
# 8. the deliverable: this directory; a grep for the fenced names reads 0
