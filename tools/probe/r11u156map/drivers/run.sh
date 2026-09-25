#!/bin/bash
# The r11u156 map pipeline (seventh edition, measurement only), map 6's drivers adapted. Inputs: the READ-ONLY
# 89d599ef reference sweep SW=/tmp/intr11u153 (<corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt}, <corpus>.csv,
# probe/<rel with / -> __>.uhdm), whose status and strict columns equal results/golden_*.csv row for row.
# W = scratch work dir. Frozen binaries (chmod 555, before any measurement) in B=/tmp/r11u156_bin:
# slang-uhdm (89d599ef), slang-uhdm.g1 (-g1, gdb only), slang-uhdm.law (89d599ef + r11u151's law_after_r11u145.patch
# + evidence/pairB_c3_scratch.patch, MEASUREMENT ONLY), uhdm-strictcmp (the committed tool), strictcmp_x (drivers/cc.sh),
# objrank (objrank.cpp). Env: SW W B + the pins (/tmp/r11u156_env.sh). The slang-fenced rows are never dispatched and
# their databases never read (jobs.py, pinmulti.py, final.py read the names from RESUME.md; redact.py writes FENCED_n).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results; MAIN=/home/heyfey/git-repos/slang-uhdm
M6=$REPO/tools/probe/r11u150map
: "${SW:?}" "${W:?}" "${B:?}"
mkdir -p "$W"; cd "$W"; export R11U138_TMP=$W/tmp SCMP=$B/strictcmp_x
# 1. jobs: every STRICT_NOTEQUAL row-mode of the committed baselines (321; 319 dispatched, 2 fenced), every probe case (4087)
python3 "$DR/jobs.py" "$RES/golden_surelog.csv" "$RES/golden_uhdm2rtlil.csv" "$SW" jobs_int.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$W/dumps xargs -P3 -n5 "$DR/run1.sh"
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" "$SW/probe" "$W/probejobs.tsv" && python3 "$DR/probelaw.py" ) | grep -P '\t' > probe_law.tsv
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=$W/pdumps xargs -P3 -n5 "$DR/run1.sh"
: > probe_ne.tsv; : > probe_verdict.tsv
while IFS=$'\t' read c m n g o rel; do f=$W/pdumps/probe/default/$n.out
  if grep -q '^rc=2' "$f"; then printf '%s\t%s\t%s\t%s\t%s\t%s\n' $c $m $n $g $o $rel >> probe_ne.tsv
    printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $f | cut -d' ' -f2)" >> probe_verdict.tsv; fi
done < probejobs.tsv
# 2. align + facets (the committed mode-4 rule, verified per row against the tool's stdout)
python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 3
python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
# 3. ids (map 6's persist; new from N2390); residue routes (the live briefs' residue cases through casekeys.sh,
#    evidence/residue_cases.txt; the routes themselves: evidence/residue_routes.json, evidence/shape_routes.json)
echo '{}' > sites.json; cp "$DR/../evidence/residue_routes.json" "$DR/../evidence/shape_routes.json" "$DR/../evidence/decoded_sites.json" "$DR/../evidence/ground_override.json" .
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final0.txt
SLANG_UHDM=$B/slang-uhdm SCX=$B/strictcmp_x W=$W "$DR/residue_cases.sh" > residue_cases.txt
# 4. pins: one gdb run per example row (the MAIN checkout's case dirs: db=SAME/DIFF against the reference database) for
#    every cluster that is new, or whose example object changed since map 6, among those with >= 3 row-modes, first on
#    a fail row, covered, or >= 40 probe cases; every other keeps map 6's pin
python3 - <<'PY'
import csv
N = {r['cluster_id']: r for r in csv.DictReader(open('out/cluster_index.csv'))}
first = {r['first_cluster'] for r in csv.DictReader(open('out/fail_list.csv'))}
want = {c for c, r in N.items() if (int(r['rows']) >= 3 or c in first or r['coverage'].startswith('COVERED') or int(r['probe_cases']) >= 40 or c >= 'N2390') and (r['example_as_map6'] == 'no' or r['site'] in ('-', ''))}
open('pinwant.txt', 'w').write(' '.join(sorted(want)))
PY
for p in 0 1; do PART=$p/2 python3 "$DR/pinmulti.py" "$W" "$MAIN" "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp$p" "$W/pins_new$p.txt" $(cat pinwant.txt) > pinmulti$p.log 2>&1 & done; wait
cat pins_new0.txt pins_new1.txt > pins_new.txt
python3 "$DR/sites.py" pins_new.txt sites_new.json "$REPO/src"
python3 "$DR/mksites7.py" pins_new.txt sites_new.json "$M6" decoded_sites.json sites.json
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final.txt
# 5. the law MEASURED: 89d599ef + r11u151's law_after_r11u145.patch + evidence/pairB_c3_scratch.patch (worktree
#    /tmp/wt_r11u156law, -j 2), a sweep of probe + both corpora (/tmp/r11u156swM), its STRICT_NOTEQUAL rows re-dumped
#    and re-keyed (WS)
( cd /tmp/wt_r11u156law && SLANG_UHDM=$B/slang-uhdm.law STRICT_CMP=$B/uhdm-strictcmp tests/sweep.sh --jobs 3 --workdir /tmp/r11u156swM --corpus "probe surelog uhdm2rtlil" > /tmp/r11u156swM.log 2>&1 ) || true
WS=/tmp/r11u156_WS; mkdir -p $WS/tmp; ( cd $WS
  python3 "$DR/jobs.py" /tmp/r11u156swM/surelog.csv /tmp/r11u156swM/uhdm2rtlil.csv /tmp/r11u156swM jobs_int.tsv
  awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WS/dumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl $WS/dumps 3
  python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('/tmp/r11u156swM/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/r11u156swM/probe/'+n+'.uhdm',rel])+'\n')"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WS/pdumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl $WS/pdumps 3 )
# 5b. pass 147 (b6af876c) LANDED while this map ran: its integration sweep /tmp/intr11u153's successor /tmp/intr11u147
#     (READ-ONLY; its csvs equal results/golden_*.csv at b6af876c row for row) re-dumped and re-keyed the same way (WS2)
G=$W/golden_b6af876c; mkdir -p $G; for f in golden_surelog golden_uhdm2rtlil golden_probe downstream_uhdm2rtlil; do git -C "$MAIN" show b6af876c:results/$f.csv > $G/$f.csv; done
WS2=/tmp/r11u156_WS2; mkdir -p $WS2/tmp; ( cd $WS2
  python3 "$DR/jobs.py" $G/golden_surelog.csv $G/golden_uhdm2rtlil.csv /tmp/intr11u147 jobs_int.tsv
  awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WS2/dumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS2/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl $WS2/dumps 3
  python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('$G/golden_probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/intr11u147/probe/'+n+'.uhdm',rel])+'\n')"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WS2/pdumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS2/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl $WS2/pdumps 3 )
# 6. tables (report7.py rewrites cluster_index / fail_list / probe_fail_list in place: start from final.py's)
for f in cluster_index fail_list probe_fail_list; do cp out/$f.csv out/$f.base.csv; done
python3 "$DR/report7.py" "$W" "$WS" "$W/out" /tmp/r11u156swM "$M6" ground_override.json > report.txt
rm -rf out147; mkdir out147; for f in cluster_index fail_list probe_fail_list; do cp out/$f.base.csv out147/$f.csv; done; cp out/clusters.csv out/probe_clusters.csv out/family_index.csv out147/
R11U156_P147=1 python3 "$DR/report7.py" "$W" "$WS2" "$W/out147" /tmp/intr11u147 "$M6" ground_override.json > report147.txt
python3 "$DR/audit147.py" out "$WS2" "$G" "$W" > audit147.txt
python3 "$DR/structural.py" out147 > structural147.txt; python3 "$DR/greedy_sets.py" out147 "$REPO" > greedy_sets147.txt
python3 "$DR/tables7.py" "$W" > tables.md
python3 "$DR/structural.py" out > structural.txt
python3 "$DR/greedy_sets.py" out "$REPO" > greedy_sets.txt
python3 - <<'PY' > evwant.txt
import csv
r = list(csv.DictReader(open('out/cluster_index.csv')))
print(' '.join(sorted(x['cluster_id'] for x in r if int(x['rows']) > 0 or int(x['probe_cases']) >= 3)))
PY
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat evwant.txt)
python3 "$DR/rowobjects.py" "$W" "$W/row_objects.csv"
# 7. the deliverable (this directory); no artifact spells a slang-fenced name
M=$DR/..
for f in clusters probe_clusters fail_list probe_fail_list cluster_index family_index; do cp out/$f.csv "$M/"; done
cp out147/fail_list.csv "$M/fail_list_p147.csv"; cp out147/probe_fail_list.csv "$M/probe_fail_list_p147.csv"; cp out147/cluster_index.csv "$M/cluster_index_p147.csv"
rm -rf "$M/evidence/clusters"; cp -r ev/clusters "$M/evidence/"
cp ev/objects.csv row_objects.csv final.txt report.txt report147.txt structural.txt structural147.txt greedy_sets.txt greedy_sets147.txt audit147.txt tables.md pins_new.txt sites.json pinwant.txt residue_cases.txt residue_routes.json shape_routes.json "$M/evidence/"
python3 "$DR/redact.py" "$REPO" "$M"
