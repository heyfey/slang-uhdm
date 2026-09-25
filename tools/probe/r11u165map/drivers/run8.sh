#!/bin/bash
# The r11u165 map pipeline (eighth edition, measurement only), as run. Inputs: the READ-ONLY f2f2d30b HEAD sweep
# SW=/tmp/intr11u163 (<corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt}, <corpus>.csv, probe/<rel with / -> __>.uhdm),
# whose status and strict columns equal results/golden_*.csv row for row. W = scratch work dir. Frozen binaries
# (chmod 555, before any measurement) in B=/tmp/r11u165_bin: slang-uhdm (f2f2d30b), slang-uhdm.dec (f2f2d30b +
# evidence/decodes_scratch.patch: r11u166 law_on_d48f8f8a8 + litall + macroconn + r11u161 law.patch, MEASUREMENT
# ONLY), slang-uhdm.g1 (-g1, gdb only), slang-uhdm.0f60 / .d48f (0f607463 / d48f8f8a, the UVM distance only),
# uhdm-strictcmp (the committed tool), strictcmp_x (drivers/cc.sh), objrank. Env: evidence/env.sh.txt (the pins,
# FENCED built from RESUME.md). The slang-fenced rows are never dispatched and their databases never read (jobs.py,
# pinmulti.py, bvmirror.sh, uvmdist.sh, dsfaces.py read the names from RESUME.md; redact.py writes FENCED_n).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results; MAIN=/home/heyfey/git-repos/slang-uhdm
: "${SW:?}" "${W:?}" "${B:?}" "${FENCED:?}"
mkdir -p "$W"; cd "$W"; export R11U138_TMP=$W/tmp SCMP=$B/strictcmp_x
# 1. jobs: every STRICT_NOTEQUAL row-mode of the committed baselines (151, none fenced), every probe case (4087)
python3 "$DR/jobs.py" "$RES/golden_surelog.csv" "$RES/golden_uhdm2rtlil.csv" "$SW" jobs_int.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$W/dumps xargs -P3 -n5 "$DR/run1.sh"
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" "$SW/probe" "$W/probejobs.tsv" && python3 "$DR/probelaw.py" ) | grep -P '\t' > probe_law.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=$W/pdumps xargs -P3 -n5 "$DR/run1.sh"
: > probe_ne.tsv; : > probe_verdict.tsv
while IFS=$'\t' read c m n g o rel; do f=$W/pdumps/probe/default/$n.out
  if grep -q '^rc=2' "$f"; then printf '%s\t%s\t%s\t%s\t%s\t%s\n' $c $m $n $g $o $rel >> probe_ne.tsv
    printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $f | cut -d' ' -f2)" >> probe_verdict.tsv; fi
done < probejobs.tsv
cp $SW/surelog.csv sweep_surelog.csv; cp $SW/uhdm2rtlil.csv sweep_uhdm2rtlil.csv; cp $SW/probe.csv sweep_probe.csv
# 2. align + facets (the committed mode-4 rule, verified per row against the tool's stdout)
python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 3
python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
# 3. ids (map 7's persist; new from N2400), pristine tables
python3 "$DR/final8.py" "$W" "$REPO" "$W/out" "$SW" > final8.txt
# 4. pins: one gdb run per example row (the MAIN checkout's case dirs, db=SAME/DIFF against the reference database) for
#    every cluster with >= 3 row-modes, first on a fail row, >= 40 probe cases or new, whose example object changed
python3 - <<'PY'
import csv
R = list(csv.DictReader(open('out/pristine_index.csv')))
first = {r['cluster_id'] for r in R if int(r['first_in_rows']) > 0}
want = [r['cluster_id'] for r in R if (int(r['rows']) >= 3 or r['cluster_id'] in first or int(r['probe_cases']) >= 40 or r['cluster_id'] >= 'N2400') and r['example_as_map7'] == 'no']
open('pinwant.txt', 'w').write(' '.join(sorted(want)))
PY
for p in 0 1; do PART=$p/2 python3 "$DR/pinmulti.py" "$W" "$MAIN" "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp$p" "$W/pins_new$p.txt" $(cat pinwant.txt) > pinmulti$p.log 2>&1 & done; wait
cat pins_new0.txt pins_new1.txt > pins_new.txt; echo '{}' > decoded_sites.json
python3 "$DR/sites.py" pins_new.txt sites_new.json "$REPO/src"
python3 "$DR/mksites8.py" pins_new.txt sites_new.json "$REPO/tools/probe/r11u156map" decoded_sites.json sites.json
# 5. the decodes MEASURED: a full gate sweep of slang-uhdm.dec (/tmp/r11u165swL, from its scratch worktree), its
#    STRICT_NOTEQUAL rows re-dumped and re-keyed (WS); per-decode attribution with R11U161_OFF / R11U166_OFF re-runs
WS=/tmp/r11u165_WS; mkdir -p $WS/tmp; ( cd $WS
  python3 "$DR/jobs.py" /tmp/r11u165swL/surelog.csv /tmp/r11u165swL/uhdm2rtlil.csv /tmp/r11u165swL jobs_int.tsv
  python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('/tmp/r11u165swL/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/r11u165swL/probe/'+n+'.uhdm',rel])+'\n')"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WS/dumps xargs -P3 -n5 "$DR/run1.sh"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WS/pdumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl $WS/dumps 3
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl $WS/pdumps 3 )
# 6. tables, audit, evidence (routes.json / ground_override.json: evidence/, hand-written from the pass READMEs)
python3 "$DR/report8.py" "$W" "$WS" "$W/out" /tmp/r11u165swL routes.json ground_override.json "$REPO" > report.txt
python3 "$DR/audit8.py" "$MAIN" "$W" "$W/out" > audit.txt
python3 - <<'PY' > evwant.txt
import csv
r = list(csv.DictReader(open('out/cluster_index.csv')))
print(' '.join(sorted(x['cluster_id'] for x in r if int(x['rows']) > 0 or int(x['probe_cases']) >= 3)))
PY
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat evwant.txt)
# 7. the UVM order-blind distance and the downstream faces
bash "$DR/uvmdist.sh" before158=/tmp/r11u165_uvm_0f60 after160=/tmp/r11u165_uvm_d48f head=/tmp/r11u165swP/surelog decodes=/tmp/r11u165swL/surelog > uvmdist.txt
# 8. the deliverable (this directory); no artifact spells a slang-fenced name
M=$DR/..
for f in clusters probe_clusters fail_list probe_fail_list cluster_index; do cp out/$f.csv "$M/"; done
rm -rf "$M/evidence/clusters"; cp -r ev/clusters "$M/evidence/"
cp ev/objects.csv report.txt audit.txt final8.txt routes.json ground_override.json sites.json pins_new.txt pinwant.txt "$M/evidence/"
python3 "$DR/redact.py" "$REPO" "$M"
