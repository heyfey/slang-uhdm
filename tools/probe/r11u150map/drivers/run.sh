#!/bin/bash
# The r11u150 map pipeline (sixth edition, measurement only), maps 3-5's drivers adapted. Inputs: the READ-ONLY
# 98aa49db reference sweep SW=/tmp/intr11u149 (<corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt}, <corpus>.csv,
# probe/<rel with / -> __>.uhdm), whose status and strict columns equal results/golden_*.csv row for row.
# W = scratch work dir. Frozen binaries (chmod 555, before any measurement) in B=/tmp/r11u150_bin:
# slang-uhdm (98aa49db), slang-uhdm.g1 (-g1, gdb only), slang-uhdm.share (98aa49db + r11u148share's law.patch,
# MEASUREMENT ONLY), uhdm-strictcmp (the committed tool), strictcmp_x (drivers/cc.sh), objrank (objrank.cpp).
# Env: SW W B + the pins (SURELOG SURELOG_ROOT UHDM2RTLIL_TESTS UHDM_CMP ...).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results; MAIN=/home/heyfey/git-repos/slang-uhdm
M5=$REPO/tools/probe/r11u142map
: "${SW:?}" "${W:?}" "${B:?}"
mkdir -p "$W"; cd "$W"; export R11U138_TMP=$W/tmp SCMP=$B/strictcmp_x
# 1. jobs: every STRICT_NOTEQUAL row-mode of the committed baselines (360), every probe case (4087); strict runs
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
# 3. ids (map 5's persist; new from N2383), residue routes (the pass READMEs' residue cases through casekeys.sh)
echo '{}' > sites.json; cp "$DR/../evidence/residue_routes.json" "$DR/../evidence/decoded_sites.json" "$DR/../evidence/ground_override.json" .
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final0.txt
( cd "$REPO/tools/probe" && export SLANG_UHDM=$B/slang-uhdm SCX=$B/strictcmp_x W
  for c in r11v140repro/plv/v05_task r11v140repro/plv/v07_basesel_opidx r11v140repro/plv/v11_incdec r11v140repro/stm/b05_comment \
           r11v140repro/stm/b04_macro r11v140repro/sca/a25_nested_bitsel_in_range r11u137repro/grid/hb/hb07_port_range \
           v11u144repro/brk/hg/x1 v11u144repro/brk/hg/x2 v11u144repro/brk/hg/x4 v11u144repro/brk/hg/x5 v11u144repro/brk/fb/x4 \
           v11u144repro/brk/el/x3 v11u144repro/brk/pf/x3 v11u144repro/brk/pf/x4 r11u149verify/cases/el/n08_nested_gen_member \
           r11u139netbind/cases/pc/pc31_bitsel_first_pos r11u139netbind/cases/pc/pc33_sel_index_whole \
           r11u148share/cases/E/e12_local_packed_arg r11u148share/cases/E/f08_param_arith; do
    "$DR/casekeys.sh" "$PWD/$c" $(echo $c | tr / _) 2>/dev/null | tail -1; done
  for c in v11u144repro/brk/el/x1 v11u144repro/brk/el/x3 r11u149verify/cases/el/n06_inst_array_prop r11u149verify/cases/el/n08_nested_gen_member; do
    ELAB=1 "$DR/casekeys.sh" "$PWD/$c" $(echo $c | tr / _)_elab 2>/dev/null | tail -1; done ) > residue_cases.txt
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final0.txt
# 4. pins: one gdb run per example row (the MAIN checkout's case dirs, so the run's database is byte-comparable with
#    the reference one: db=SAME/DIFF) for every cluster that is new, or whose example object changed since map 5,
#    among those with >= 3 row-modes, first on a fail row, covered, or >= 40 probe cases; every other keeps map 5's pin
python3 - <<'PY'
import csv
N = {r['cluster_id']: r for r in csv.DictReader(open('out/cluster_index.csv'))}
first = {r['first_cluster'] for r in csv.DictReader(open('out/fail_list.csv'))}
want = {c for c, r in N.items() if (int(r['rows']) >= 3 or c in first or r['coverage'].startswith('COVERED') or int(r['probe_cases']) >= 40 or c >= 'N2383') and (r['example_as_map5'] == 'no' or r['site'] in ('-', ''))}
open('pinwant.txt', 'w').write(' '.join(sorted(want)))
PY
PART=0/1 python3 "$DR/pinmulti.py" "$W" "$MAIN" "$B/objrank" "$B/strictcmp_x" "$B/slang-uhdm.g1" "$W/dumps" "$W/pdumps" "$W/pmtmp" "$W/pins_new.txt" $(cat pinwant.txt) > pinmulti.log 2>&1
python3 "$DR/sites.py" pins_new.txt sites_new.json "$REPO/src"
python3 "$DR/mksites6.py" pins_new.txt sites_new.json "$M5" decoded_sites.json sites.json
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final.txt
# 5. the share law MEASURED: 98aa49db + tools/probe/r11u148share/law.patch (worktree /tmp/wt_r11u150share, -j 2),
#    a full sweep of probe + both corpora (/tmp/r11u150_swS), its STRICT_NOTEQUAL rows re-dumped and re-keyed (WS)
( cd /tmp/wt_r11u150share && SLANG_UHDM=$B/slang-uhdm.share STRICT_CMP=$B/uhdm-strictcmp tests/sweep.sh --jobs 3 --workdir /tmp/r11u150_swS --corpus "probe surelog uhdm2rtlil" > /tmp/r11u150_swS.log 2>&1 ) || true
WS=/tmp/r11u150_workS; mkdir -p $WS/tmp; ( cd $WS
  python3 "$DR/jobs.py" /tmp/r11u150_swS/surelog.csv /tmp/r11u150_swS/uhdm2rtlil.csv /tmp/r11u150_swS jobs_int.tsv
  awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WS/dumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl $WS/dumps 3
  python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('/tmp/r11u150_swS/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/r11u150_swS/probe/'+n+'.uhdm',rel])+'\n')"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WS/pdumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WS/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl $WS/pdumps 3 )
# 6. tables (report6.py rewrites cluster_index / fail_list / probe_fail_list in place: start from final.py's)
for f in cluster_index fail_list probe_fail_list; do cp out/$f.csv out/$f.base.csv; done
python3 "$DR/report6.py" "$W" "$WS" "$W/out" /tmp/r11u150_swS "$M5" ground_override.json > report.txt
python3 "$DR/structural.py" out > structural.txt
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
rm -rf "$M/evidence/clusters"; cp -r ev/clusters "$M/evidence/"
cp ev/objects.csv row_objects.csv final.txt report.txt structural.txt pins_new.txt sites.json pinwant.txt residue_cases.txt tallies.txt "$M/evidence/"
python3 "$DR/redact.py" "$REPO" "$M"
