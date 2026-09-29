#!/bin/bash
# The r11u222 map pipeline (fourteenth edition, measurement only), as run. No source edit anywhere. The caller sets
# the scratch locations; this pass used one pass-prefixed root <P> (15-character sweep workdirs <P>sP, <P>sL, <P><k>):
#   MAP_W=<P>W MAP_BIN=<P>bin MAP_H=<the HEAD integration sweep> SWPFX=<P> SP=<P>sP LSW=<P>sL WS=<P>WS LCEN=<P>cen
# Binaries (frozen chmod 555 in $MAP_BIN before any measurement): slang-uhdm (the worktree build at 896ec643, md5
# b47000e7 = the main tree's), slang-uhdm.rebuild2 (a second worktree, fresh build dir: b47000e7 too),
# slang-uhdm.law218 (896ec643 + tools/probe/r11u218dec/law_exprstmt.patch applied as is in the second worktree,
# incremental build: e973c16f), slang-uhdm.g1 (-DCMAKE_CXX_FLAGS=-g1, target slang_uhdm: 1af6c072), uhdm-strictcmp
# (fa6e4f42), strictcmp_x (drivers/cc.sh: 5bbd7f83), objrank (3e213a15), sym and ord (r11u221's sources), and the
# state wrappers st<k>.sh = `exec env <switches> $MAP_BIN/slang-uhdm "$@"` (section 8 of the README).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); . "$DR/env.sh"; E=$DR/../evidence
export SWPFX=${SWPFX:?} SP=${SP:?} LSW=${LSW:?} WS=${WS:?} LCEN=${LCEN:?}
# 1. jobs + strict runs over the HEAD sweep: every STRICT_NOTEQUAL row-mode (33) and every probe case (4087)
mkdir -p $W; cd $W
python3 "$DR/jobs.py" "$REPO/results/golden_surelog.csv" "$REPO/results/golden_uhdm2rtlil.csv" $H jobs_int.tsv
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
# 2. ids (map 13's persist; N2470 by hand, the addendum's key)
python3 "$DR/final14.py" "$W" "$REPO" "$W/out" $H > final14.txt
# 3. the pristine gate sweep, the firing census of law218 (the mover PREDICTION, frozen chmod 444 with md5 before the
#    law sweep) and law218's full gate sweep; byteverify of both against the reference and each other
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm tests/sweep.sh --jobs 3 --workdir $SP ) > $SP.log 2>&1 || true
CJOBS=2 bash "$DR/lawsweep.sh"
bash "$DR/bvmirror.sh" $H ${SWPFX}bvH; bash "$DR/bvmirror.sh" $SP ${SWPFX}bvP; bash "$DR/bvmirror.sh" $LSW ${SWPFX}bvL
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" ${SWPFX}bvP ${SWPFX}bvH
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" ${SWPFX}bvL ${SWPFX}bvP
# 4. the r11u218 cross-section MEASURED (the law sweep's STRICT_NOTEQUAL rows and cases re-dumped and re-keyed: WS)
bash "$DR/crosssection.sh"
# 5. pins: one gdb run per example row for the clusters whose example object changed since map 13 (>= 3 row-modes,
#    a first record or >= 40 cases; coin-only UVM clusters keep map 13's pin) and the new keys; REPO for the gdb runs
#    is the MAIN tree, whose case paths the reference probe databases embed
echo "N0039 N0423 N0131 N0011 N0427 N2470 N2471 N2472 N2473 N0989" > $W/pinwant.txt
PART=0/1 python3 "$DR/pinmulti.py" "$W" /home/heyfey/git-repos/slang-uhdm "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp0" "$W/pins_new0.txt" $(cat $W/pinwant.txt)
python3 "$DR/sites.py" $W/pins_new0.txt $W/sites_new.json $REPO/src
python3 -c "import json; s=json.load(open('$W/sites_new.json')); json.dump({k: v['site'] + ' [r11u222 pin]' for k, v in s.items()}, open('$W/sites.json', 'w'), indent=1)"
# 6. routes, report, tables, audit, evidence
python3 "$DR/mkroutes14.py" "$REPO" "$E/routes.json" "$E/ground_override.json"
python3 "$DR/report14.py" "$W" $WS "$W/out" $LSW "$E/routes.json" "$E/ground_override.json" "$REPO" > $W/report.txt
( cd /home/heyfey/git-repos/slang-uhdm && python3 "$DR/audit14.py" /home/heyfey/git-repos/slang-uhdm "$W/out" ) > $W/audit.txt
python3 -c "import csv; print(' '.join(r['cluster_id'] for r in csv.DictReader(open('$W/out/cluster_index.csv')) if int(r['rows']) > 0 or int(r['probe_cases']) >= 3))" > $W/evwant.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat $W/evwant.txt)
mkdir -p $W/tables; for t in t1 nonfam fail pfirst newc; do python3 "$DR/tables14.py" "$W/out" $t 40 > $W/tables/t_$t.md; done
# 7. the landing-off state sweeps and the away census of every landing since map 13 (both record forms, chain-keyed
#    and flat with the position-aware reading), the r11u218 patch and the reversed controls
bash "$DR/statesweeps.sh" a9 b3 c0 d2 e7 f6 g5 h1 i9
bash "$DR/awaylandings.sh" a9 b3 c0 d2 L e7 f6 g5 h1 i9 RL Ri9
# 8. UVM census and distance, downstream faces, positive controls, determinism, the coin's writer, rebuild identity
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm; bash "$DR/uvmcensus9.sh" $WS/corpus.jsonl $W/uvmL
UVMDIST_TESTS="MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg Earlgrey_0_1 Rggen Scr1SvTests BlackBePipeInt InterfArrayBind FuncStructVal" UVMDIST_TMP=$W/uvmdistH bash "$DR/uvmdist.sh" $H > $W/uvmdist_H.txt
UVMDIST_TESTS="MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg Earlgrey_0_1" UVMDIST_TMP=$W/uvmdistL bash "$DR/uvmdist.sh" $LSW > $W/uvmdist_L.txt
( cd $REPO && GOLDEN_CACHE=${SWPFX}dsgold SLANG_UHDM=$B/slang-uhdm DSJOBS=2 python3 "$DR/dsfaces.py" $REPO ${SWPFX}dsP $W/dsfaces_P.csv @$E/downstream/ds_cases.txt )
( cd $REPO && GOLDEN_CACHE=${SWPFX}dsgold SLANG_UHDM=$B/slang-uhdm.law218 DSJOBS=2 python3 "$DR/dsfaces.py" $REPO ${SWPFX}dsL $W/dsfaces_L.csv @$E/downstream/ds_cases.txt )
DETOUT=$W/det/head bash "$DR/det.sh" > $W/det_head.txt; DETOUT=$W/det/head DETSORT=$W/det/sorted bash "$DR/ob.sh" > $W/det_ob.txt
bash "$DR/pinsym.sh" MiniAmiq default "uvm_pkg::uvm_report_object::uvm_report_info::verbosity::UVM_MEDIUM" $W/det/pinsym_B
BINS="slang-uhdm slang-uhdm.rebuild2 slang-uhdm.g1 slang-uhdm.law218" N=3 bash "$DR/rebuildid.sh" $W/rebuild tools/probe/r11u196repro/cases/V191/qr01 tools/probe/r11u209repro/cases/TW/qr01 > $W/rebuildid.txt
# 9. the deliverable: this directory; a grep for the fenced names reads 0
