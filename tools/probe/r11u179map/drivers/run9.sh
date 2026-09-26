#!/bin/bash
# The r11u179 map pipeline (ninth edition, measurement only), as run. No source edit anywhere: the pristine binary is
# the worktree build of 5e8d08d9; the r11u175 binary is 5e8d08d9 + evidence/law175_scratch.patch (= r11u175's
# law_exprstmt.patch + law_typeemit.patch, both clean `git apply`) built in a scratch worktree, MEASUREMENT ONLY.
# Every driver that reads a database or a source refuses the four slang-fenced names (common.fenced(): the FENCED=
# line of tools/probe/r11u107repro/canaudit.sh; fail closed); the gate sweeps dispatch every row as the gate mandates.
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results
. "$DR/env.sh"          # pins, B=/tmp/r11u179_bin, W=/tmp/r11u179_W, FENCED
WS=/tmp/r11u179_WS
# 0. binaries, frozen chmod 555 in $B BEFORE any measurement
#    slang-uhdm (9958104447d8 = main tree), uhdm-strictcmp (5d4617d0), strictcmp_x (drivers/cc.sh, db96066a),
#    objrank, slang-uhdm.law175 (25b3b98b), slang-uhdm.g1 (-DCMAKE_CXX_FLAGS=-g1, gdb only)
# 1. the gate sweeps of both binaries from the worktree (same-length workdirs)
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm tests/sweep.sh --jobs 3 --workdir /tmp/r11u179_swP ) > /tmp/r11u179_swP.log 2>&1 || true
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm.law175 tests/sweep.sh --jobs 3 --workdir /tmp/r11u179_swL ) > /tmp/r11u179_swL.log 2>&1 || true
# 2. jobs: every STRICT_NOTEQUAL row-mode (98) and every probe case (4087; rc=2 on the 1291 NE), strict runs with dumps
mkdir -p $W $WS; cd $W; export R11U138_TMP=$W/tmp SCMP=$B/strictcmp_x
python3 "$DR/jobs.py" "$RES/golden_surelog.csv" "$RES/golden_uhdm2rtlil.csv" /tmp/r11u179_swP jobs_int.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$W/dumps xargs -P3 -n5 "$DR/run1.sh"
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" /tmp/r11u179_swP/probe "$W/probejobs.tsv" && python3 "$DR/probelaw.py" ) | grep -P '\t' > probe_law.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=$W/pdumps xargs -P3 -n5 "$DR/run1.sh"
: > probe_ne.tsv; : > probe_verdict.tsv
while IFS=$'\t' read c m n g o rel; do f=$W/pdumps/probe/default/$n.out
  if grep -q '^rc=2' "$f"; then printf '%s\t%s\t%s\t%s\t%s\t%s\n' $c $m $n $g $o $rel >> probe_ne.tsv
    printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $f | cut -d' ' -f2)" >> probe_verdict.tsv; fi
done < probejobs.tsv
cp /tmp/r11u179_swP/surelog.csv sweep_surelog.csv; cp /tmp/r11u179_swP/uhdm2rtlil.csv sweep_uhdm2rtlil.csv; cp /tmp/r11u179_swP/probe.csv sweep_probe.csv
python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 3
python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
# 3. ids (map 8's persist; new from N2411), pristine tables
python3 "$DR/final9.py" "$W" "$REPO" "$W/out" /tmp/r11u179_swP > final9.txt
# 4. pins: one gdb run per example row for the wanted clusters (pinwant.txt: >= 3 row-modes, first on a fail row,
#    >= 40 probe cases or not in map 8, whose example object changed since map 8); the three UVM-coin clusters were
#    re-pinned on SimpleUVM (pins_retryX.txt) and their ranks verified against the gdb run's own database
for p in 0 1; do PART=$p/2 python3 "$DR/pinmulti.py" "$W" "$REPO" "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp$p" "$W/pins_new$p.txt" $(cat pinwant.txt) > pinmulti$p.log 2>&1 & done; wait
cat pins_new0.txt pins_new1.txt > pins_new.txt    # + pins_retryX.txt merged as db=DIFF-rankverified -> pins_final.txt
python3 "$DR/sites.py" pins_final.txt sites_new.json "$REPO/src"
python3 "$DR/mksites9.py" pins_final.txt sites_new.json "$REPO/tools/probe/r11u165map" sites.json
# 5. the r11u175 cross-section MEASURED: the law sweep's STRICT_NOTEQUAL rows re-dumped and re-keyed
( cd $WS
  python3 "$DR/jobs.py" /tmp/r11u179_swL/surelog.csv /tmp/r11u179_swL/uhdm2rtlil.csv /tmp/r11u179_swL jobs_int.tsv
  python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('/tmp/r11u179_swL/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/r11u179_swL/probe/'+n+'.uhdm',rel])+'\n')"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WS/dumps xargs -P3 -n5 "$DR/run1.sh"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WS/pdumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl $WS/dumps 3
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl $WS/pdumps 3 )
# 6. tables, audit, evidence
python3 "$DR/report9.py" "$W" "$WS" "$W/out" /tmp/r11u179_swL "$DR/../evidence/routes.json" "$DR/../evidence/ground_override.json" "$REPO" > report.txt
python3 "$DR/audit9.py" "$REPO" "$W/out" > audit.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat evwant.txt)
# 7. the UVM census (r11u175's F1-F9 over map 8's keys), the order-blind distance, the downstream faces, byte movers,
#    the per-patch attribution (R11U175_FSPAN_OFF / R11U175_MULT_OFF+FULLNAME_OFF+ESPAN_OFF), canaries
bash "$DR/uvmcensus9.sh" $W/corpus.jsonl $W/uvm; bash "$DR/uvmcensus9.sh" $WS/corpus.jsonl $WS/uvm
bash "$DR/uvmdist.sh" /tmp/r11u179_swP /tmp/r11u179_swL > /tmp/r11u179_uvmdist.txt
GOLDEN_CACHE=/tmp/r11u179_dsgold SLANG_UHDM=$B/slang-uhdm python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u179_dsP /tmp/r11u179_dsfaces_P.csv $(cat /tmp/r11u179_dscases/list.txt) /tmp/r11u179_dscases/LT/l01 /tmp/r11u179_dscases/LT/l02
GOLDEN_CACHE=/tmp/r11u179_dsgold SLANG_UHDM=$B/slang-uhdm.law175 python3 "$DR/dsfaces.py" "$REPO" /tmp/r11u179_dsL /tmp/r11u179_dsfaces_L.csv $(cat /tmp/r11u179_dscases/list.txt) /tmp/r11u179_dscases/LT/l01 /tmp/r11u179_dscases/LT/l02
bash "$DR/bvmirror.sh" /tmp/r11u179_swP /tmp/r11u179_bvP; bash "$DR/bvmirror.sh" /tmp/r11u179_swL /tmp/r11u179_bvL; bash "$DR/bvmirror.sh" /tmp/intr11u177 /tmp/r11u179_bvH
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" /tmp/r11u179_bvL /tmp/r11u179_bvP
SELFCHECK=1 bash "$REPO/tools/probe/r11v75repro/byteverify.sh" /tmp/r11u179_bvP /tmp/r11u179_bvH
# 8. the deliverable: this directory (clusters, fail lists, index, evidence); a grep for the fenced names reads 0
