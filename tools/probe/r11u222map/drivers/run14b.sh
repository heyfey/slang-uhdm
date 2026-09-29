#!/bin/bash
# The r11u222 map pipeline (fourteenth edition, measurement only), AS RUN AT THE RESTART on 551c9751 (pass 220 landed).
# No source edit anywhere. The caller sets the scratch locations; this run used one pass-prefixed root <P> with the
# sweep workdirs <P>sP (the pristine gate sweep) and <P><k> (the landing-off state sweeps), all 16 characters long:
#   MAP_W=<P>W MAP_BIN=<P>bin MAP_H=<the 551c9751 integration sweep, read-only> SWPFX=<P> SP=<P>sP
# and, for section 3, OLDW = the first run's work dir at 896ec643 (its corpus.jsonl / probe.jsonl / ids.json,
# the analysis of the 896ec643 pristine sweep that the R11U220_OFF state sweep reproduces byte for byte).
# Binaries (frozen chmod 555 in $MAP_BIN before any measurement): slang-uhdm (this checkout at 551c9751, md5 2510f4fe =
# the main tree's build = the HEAD sweep's binary), slang-uhdm.g1 (-DCMAKE_CXX_FLAGS=-g1, target slang_uhdm), a second
# independent build (build-rb2) for the rebuild identity, uhdm-strictcmp (fa6e4f42, the gate's), strictcmp_x
# (drivers/cc.sh: 5bbd7f83), objrank, sym and ord, and the state wrappers st<k>.sh = `exec env <switches> slang-uhdm`
# (README section 9).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); . "$DR/env.sh"; E=$DR/../evidence
export SWPFX=${SWPFX:?} SP=${SP:?}
# 1. jobs + strict runs over the HEAD sweep: every STRICT_NOTEQUAL row-mode (31) and every probe case (4087)
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
# (as run: the three-worker corpus analysis lost the two Earlgrey jobs to killed workers under memory pressure; they
#  were re-run with ONE worker and appended: grep Earlgrey jobs_int.tsv > jobs_earl.tsv; analyze.py ... 1)
R11U138_TMP=$W/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 1
R11U138_TMP=$W/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
# 2. ids (map 13's persist), the pristine gate sweep, the landing-off state sweeps, byte identity
python3 "$DR/final14.py" "$W" "$REPO" "$W/out" $H > final14.txt
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm tests/sweep.sh --jobs 3 --workdir $SP ) > $SP.log 2>&1 || true
for s in j0 k8 a9 b3 c0 d2 e7 f6 g5 h1 i9; do
  ( cd "$REPO" && SLANG_UHDM=$B/st$s.sh tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil" --workdir ${SWPFX}$s ) > ${SWPFX}$s.log 2>&1 || true
done
for x in "H $H" "P $SP" "J ${SWPFX}j0"; do set -- $x; bash "$DR/bvmirror.sh" $2 ${SWPFX}bv$1; done
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" ${SWPFX}bvP ${SWPFX}bvH
bash "$DR/probecmp.sh" $SP $REPO $H /home/heyfey/git-repos/slang-uhdm $W/bv/probe_P_vs_H.txt
# (the first run's 896ec643 pristine sweep, mirrored as ${SWPFX}bvO, against the R11U220_OFF state: 0 / 2560, 0 / 4087)
# 3. what pass 220 did to the map (the first run's 896ec643 analysis against this one)
python3 "$DR/landing220.py" ${OLDW:?} $W $W/ids.json $REPO/tools/probe/r11u211map/cluster_index.csv > $W/landing220.txt
# 4. pins: one gdb run per example row for the clusters whose example object changed since map 13 or the first run
#    (>= 3 row-modes, a first record, >= 40 cases, or a new key); REPO for the gdb runs is the MAIN tree, whose case
#    paths the reference probe databases embed. The first run's ten pins at 896ec643 are kept where the example is the same.
echo "N0247 N0374 N0481 N0521 N0318 N0594 N0215 N0634 N0616 N1211 N1212 N1438 N1439 N2474 N2475" > $W/pinwant.txt
PART=0/1 python3 "$DR/pinmulti.py" "$W" /home/heyfey/git-repos/slang-uhdm "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp" "$W/pins_new.txt" $(cat $W/pinwant.txt)
python3 "$DR/sites.py" $W/pins_new.txt $W/sites_new.json $REPO/src
# (sites.json = the first run's ten pins, tagged 'at 896ec643', + these fifteen: evidence/sites.json)
# 5. routes, report, tables, audit, evidence
python3 "$DR/mkroutes14b.py" "$REPO" "$W/routes.json" "$W/ground_override.json"
python3 "$DR/report14b.py" "$W" "$W/out" $H "$W/routes.json" "$W/ground_override.json" "$REPO" > $W/report.txt
( cd /home/heyfey/git-repos/slang-uhdm && python3 "$DR/audit14b.py" /home/heyfey/git-repos/slang-uhdm "$W/out" ) > $W/audit.txt
python3 -c "import csv; print(' '.join(r['cluster_id'] for r in csv.DictReader(open('$W/out/cluster_index.csv')) if int(r['rows']) > 0 or int(r['probe_cases']) >= 3))" > $W/evwant.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat $W/evwant.txt)
mkdir -p $W/tables; for t in t1 nonfam fail pfirst newc; do python3 "$DR/tables14b.py" "$W/out" $t 40 > $W/tables/t_$t.md; done
# 6. the away census of every landing since map 13 and of pass 220, at 551c9751 (both record forms, chain-keyed and
#    flat with the position-aware reading), and the reversed positive controls
bash "$DR/awaylandings.sh" j0 k8 a9 b3 c0 d2 e7 f6 g5 h1 i9 Rj0 Ri9
# 7. UVM census and distance, downstream faces, positive controls, determinism, the coin's writer, rebuild identity
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm
UVMDIST_TESTS="MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg Earlgrey_0_1 Rggen Scr1SvTests BlackBePipeInt InterfArrayBind FuncStructVal" UVMDIST_TMP=$W/uvmdistH bash "$DR/uvmdist.sh" $H > $W/uvmdist_H.txt
( cd $REPO && GOLDEN_CACHE=${SWPFX}dsgold SLANG_UHDM=$B/slang-uhdm DSJOBS=2 python3 "$DR/dsfaces.py" $REPO ${SWPFX}dsP $W/dsfaces_P.csv @$E/downstream/ds_cases.txt )
DETOUT=$W/det/head bash "$DR/det.sh" > $W/det_head.txt; DETOUT=$W/det/head DETSORT=$W/det/sorted DETTESTS='MiniAmiq Scoreboard' bash "$DR/ob.sh" > $W/det_ob.txt
$B/sym $W/det/head/MiniAmiq_default_1.uhdm > $W/det/symA.txt; $B/sym $W/det/head/MiniAmiq_default_2.uhdm > $W/det/symB.txt
bash "$DR/pinsym.sh" MiniAmiq default "svaunit_pkg::uvm_component::record_error_tr::stream.open_recorder::label" $W/det/pinsym_N
DETBIN=$B/st175.sh DETN=4 DETTESTS=MiniAmiq DETOUT=$W/det/off175 bash "$DR/det.sh" > $W/det_off175.txt
BINS="slang-uhdm slang-uhdm.rebuild2 slang-uhdm.g1" N=3 bash "$DR/rebuildid.sh" $W/rebuild tools/probe/r11u196repro/cases/V191/qr01 tools/probe/r11u209repro/cases/TW/qr01 > $W/rebuildid.txt
# 8. the deliverable: this directory; a grep for the fenced names reads 0
