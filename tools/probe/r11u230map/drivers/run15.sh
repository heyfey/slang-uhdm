#!/bin/bash
# The r11u230 map pipeline (fifteenth edition, measurement only), in the order it ran on 97343175 (2026-09-29).
# No source edit anywhere. The caller sets the scratch locations (this run: one pass-prefixed root <P>):
#   MAP_W=<P>W  MAP_BIN=<P>bin  MAP_H=<the 97343175 integration sweep, read-only>  SWPFX=<P>  SP=<P>sP
# Binaries frozen chmod 555 in $MAP_BIN before any measurement: slang-uhdm (this checkout's build, = the main tree's
# 7e50408d), slang-uhdm.rebuild2 (a second build directory from nothing), slang-uhdm.g1 (-DCMAKE_CXX_FLAGS=-g1, target
# slang_uhdm), uhdm-strictcmp (this checkout's), strictcmp_x (cc.sh), objrank (cc.sh <out> objrank.cpp), and the state
# wrappers st<k>.sh = `exec env <switches> slang-uhdm` (s4 R11U224_OFF; s5 R11U225_OFF R11V225_OFF; s6 R11V226_OFF;
# s9 R11V229_OFF). The field offsets: ccw.sh <W>/fieldoff && <W>/fieldoff > <W>/fieldoff.txt.
set -eu
DR=$(cd "$(dirname "$0")" && pwd); . "$DR/env.sh"; E=$DR/../evidence
: "${SWPFX:?}" "${SP:?}"
# 1. jobs + strict runs over the HEAD sweep (28 STRICT_NOTEQUAL row-modes, 634 STRICT_NOTEQUAL probe cases), analysis
mkdir -p $W; cd $W
python3 "$DR/jobs.py" "$REPO/results/golden_surelog.csv" "$REPO/results/golden_uhdm2rtlil.csv" $H jobs_int.tsv
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" $H/probe "$W/probejobs_all.tsv" )
python3 - "$REPO/results/golden_probe.csv" <<'PY'
import csv, sys
ne = {r['case'] for r in csv.DictReader(open(sys.argv[1])) if r['status'] == 'STRICT_NOTEQUAL'}
with open('probejobs.tsv', 'w') as f:
    for l in open('probejobs_all.tsv'):
        if l.rstrip('\n').split('\t')[5] in ne: f.write(l)
PY
ln -sf probejobs.tsv probe_ne.tsv
( cd "$REPO" && python3 "$DR/probelaw.py" ) | grep -P '\t' > probe_law.tsv
bash "$DR/strict_runs.sh"
while IFS=$'\t' read c m n g o rel; do printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $W/pdumps/probe/default/$n.out | cut -d' ' -f2)"; done < probejobs.tsv > probe_verdict.tsv
cp $H/surelog.csv sweep_surelog.csv; cp $H/uhdm2rtlil.csv sweep_uhdm2rtlil.csv; cp $H/probe.csv sweep_probe.csv
R11U138_TMP=$W/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 2
R11U138_TMP=$W/tmp python3 "$DR/analyze.py" probejobs.tsv probe.jsonl "$W/pdumps" 3
python3 "$DR/final15.py" "$W" "$REPO" "$W/out" $H > final15.txt
python3 "$DR/delta15.py" "$REPO" "$W/out" > delta15.txt
# 2. the pristine gate sweep and the landing-off state sweeps; byte movers; the pristine sweep against HEAD
bash "$DR/statesweeps.sh" s4 s5 s6 s9
bash "$DR/bvmirror.sh" $H ${SWPFX}bvH; bash "$DR/bvmirror.sh" $SP ${SWPFX}bvP
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" ${SWPFX}bvP ${SWPFX}bvH
bash "$DR/probecmp.sh" $SP $REPO $H /home/heyfey/git-repos/slang-uhdm $W/probe_P_vs_H.txt
bash "$DR/movers.sh" s4 s5 s6 s9 > movers.txt
# 3. what each landing did to the map (states with record movers)
for s in s4 s5; do python3 "$DR/statejobs.py" $REPO ${SWPFX}$s $SP $W/state_$s; done   # + run1.sh / analyze.py on each
python3 "$DR/landing15.py" $W $W/state_s4 $W/ids.json $REPO/tools/probe/r11u222map/cluster_index.csv "pass 224" > landing_s4.txt
python3 "$DR/landing15.py" $W $W/state_s5 $W/ids.json $REPO/tools/probe/r11u222map/cluster_index.csv "pass 225" > landing_s5.txt
# 4. pins: mints of the 28 changed examples (pinmulti.py + sites.py), writers of every OPEN / row cluster with a field
#    (pinwriter.py in three parts, then again on corpus rows with PW_PREFER=corpus), summarised by pwsum.py; REPO for the
#    gdb runs is the MAIN tree, whose case paths the reference probe databases embed
PART=0/1 python3 "$DR/pinmulti.py" $W /home/heyfey/git-repos/slang-uhdm $B/objrank $B/strictcmp_x $B/slang-uhdm.g1 $W/dumps $W/pdumps $W/pmtmp $W/pins_new.txt $(cat $W/pinwant.txt)
python3 "$DR/sites.py" $W/pins_new.txt $W/sites.json $REPO/src
for i in 0 1 2; do PART=$i/3 python3 "$DR/pinwriter.py" $W /home/heyfey/git-repos/slang-uhdm $B/objrank $B/strictcmp_x $B/slang-uhdm.g1 $W/dumps $W/pdumps $W/pwtmp_$i $W/pw_all_$i.jsonl $W/fieldoff.txt $(cat $W/pw_want.txt) & done; wait
for i in 0 1; do PW_PREFER=corpus PART=$i/2 python3 "$DR/pinwriter.py" $W /home/heyfey/git-repos/slang-uhdm $B/objrank $B/strictcmp_x $B/slang-uhdm.g1 $W/dumps $W/pdumps $W/pw2tmp_$i $W/pw2_$i.jsonl $W/fieldoff.txt $(cat $W/pw2_want.txt) & done; wait
python3 "$DR/pwsum.py" $REPO/src $W/sites_writer.json $W/writer_ground.json $W/pw_all_*.jsonl $W/pw_rest_*.jsonl $W/pw2_*.jsonl
# 5. routes, report, tables, rowsets, audit, evidence
python3 "$DR/mkroutes15.py" "$REPO" "$W/routes.json" "$W/ground_override.json" "$W/writer_ground.json"
python3 "$DR/report15.py" "$W" "$W/out" $H "$W/routes.json" "$W/ground_override.json" "$REPO" > $W/report.txt
for t in t1 nonfam fail pfirst newc; do python3 "$DR/tables15.py" "$W/out" $t 40 > $E/tables/t_$t.md; done
python3 "$DR/rowsets.py" $W $W/out FuncStructVal struct_param_func_config cfg_func_width_loop BlackBePipeInt > $E/rowsets.txt
( cd $REPO && python3 "$DR/audit15.py" $REPO "$W/out" ) > $W/audit.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$E" $(cat $W/evwant.txt)
# 6. the away census of every landing since map 14 and the reversed controls
bash "$DR/awaylandings.sh" s4 s5 s6 s9 Rs4 Rs5 Rs6 Rs9
# 7. UVM census and distance, downstream faces, controls, determinism, rebuild identity
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm
UVMDIST_TESTS="MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg Earlgrey_0_1 Rggen Scr1SvTests BlackBePipeInt FuncStructVal" UVMDIST_TMP=$W/uvmdistH bash "$DR/uvmdist.sh" $H > $W/uvmdist_H.txt
( cd $REPO && GOLDEN_CACHE=${SWPFX}dsgold SLANG_UHDM=$B/slang-uhdm DSJOBS=2 python3 "$DR/dsfaces.py" $REPO ${SWPFX}dsP $W/dsfaces_P.csv @$E/downstream/ds_cases.txt )
bash "$DR/controls.sh" $W/controls > $W/controls.txt
DETOUT=$W/det/head DETN=3 DETROUNDS=4 DETTESTS="MiniAmiq Scoreboard" bash "$DR/det.sh" > $W/det_head12.txt
DETOUT=$W/det/head3 DETN=3 DETTESTS="Earlgrey_0_1 SeqDriver SimpleUVM BuildUVMPkg" bash "$DR/det.sh" > $W/det_head3.txt
BINS="slang-uhdm slang-uhdm.rebuild2 slang-uhdm.g1" N=3 bash "$DR/rebuildid.sh" $W/rebuild tools/probe/r11u196repro/cases/V191/qr01 tools/probe/r11u209repro/cases/TW/qr01 > $W/rebuildid.txt
# 8. the addendum at the later HEAD (ADDSWEEP = its integration sweep, read-only): movers against $H, strict runs of the
#    moved STRICT_NOTEQUAL databases, the merged analysis, the movement, the new live pairs' routes and report
#    (statejobs.py $REPO $ADDSWEEP $H $W/add; run1.sh + analyze.py; addmerge.py $W $W/add; landing15.py $W/add/full
#    $W/add/base_moved ...; mkroutes_add.py; MAP_BASE_LABEL=<commit> report15.py $W/add/full ...)
# 4b. the head record of every fail-list row (PW_ROWS=<corpus>/<mode>/<test> pinwriter.py ... <first cluster>, one run per
#     row: pwh_<i>.jsonl), BlackBePipeInt's default row (PW_ROWS=surelog/default/BlackBePipeInt ... N0923 N1125 N2471 N0028),
#     the pass-225-off state's two conversions (pinwriter.py over the state's databases, run with its switches); headtable.py
# 9. the README: readme15.py fills README.src.md's generated tables
