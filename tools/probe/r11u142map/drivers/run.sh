#!/bin/bash
# The r11u142 map pipeline (measurement only): r11u138map's pipeline (drivers copied, adapted) on the
# READ-ONLY a7bee711 reference sweep SW=/tmp/intr11u141 (<corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt},
# <corpus>.csv, probe/<rel with / -> __>.uhdm), whose status and strict columns equal results/golden_*.csv
# row for row. W = scratch work dir. Env: SW W SCX OBJRANK G1 + the pins (SURELOG SURELOG_ROOT
# UHDM2RTLIL_TESTS ...); NB = the measurement-only binary a7bee711 + tools/probe/r11u139netbind/law.patch;
# P137 = the 6ef15be0 binary (pass 137, landed during the measurement).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results; MAIN=/home/heyfey/git-repos/slang-uhdm
: "${SW:?}" "${W:?}" "${SCX:?}" "${OBJRANK:?}" "${G1:?}" "${NB:?}" "${P137:?}"
mkdir -p "$W"; cd "$W"; export R11U138_TMP=$W/tmp SCMP=$SCX
# 1. jobs: every STRICT_NOTEQUAL row-mode of the committed baselines (517), every probe case (4087)
python3 "$DR/jobs.py" "$RES/golden_surelog.csv" "$RES/golden_uhdm2rtlil.csv" "$SW" jobs_int.tsv
DUMPS=$W/dumps; export DUMPS
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | xargs -P3 -n5 "$DR/run1.sh"
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" "$SW/probe" "$W/probejobs.tsv" && python3 "$DR/probelaw.py" ) | grep -P '\t' > probe_law.tsv
DUMPS=$W/pdumps; export DUMPS
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | xargs -P3 -n5 "$DR/run1.sh"
: > probe_ne.tsv; : > probe_verdict.tsv
while IFS=$'\t' read c m n g o rel; do f=$W/pdumps/probe/default/$n.out
  if grep -q '^rc=2' "$f"; then printf '%s\t%s\t%s\t%s\t%s\t%s\n' $c $m $n $g $o $rel >> probe_ne.tsv
    printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $f | cut -d' ' -f2)" >> probe_verdict.tsv; fi
done < probejobs.tsv
# 2. align + facets (the committed mode-4 rule, verified per row against the tool's stdout)
python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 3
python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
echo '{}' > sites.json
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final0.txt   # ids.json
# 3. pins: pinmulti (one gdb run per example row, the MAIN tree's checkout as cwd so the database is byte-comparable
#    with the reference one: db=SAME/DIFF) on every cluster with >= 3 row-modes, first on a fail row, covered,
#    >= 40 probe cases, or new; mksites.py keeps map 4's pin where the run's database differed (the UVM coin) or the
#    new example row is an --elabuhdm DeepClone; every other cluster keeps map 4's pin.
python3 - <<'PY'
import csv
N = {r['cluster_id']: r for r in csv.DictReader(open('out/cluster_index.csv'))}
first = {r['first_cluster'] for r in csv.DictReader(open('out/fail_list.csv'))}
want = {c for c, r in N.items() if int(r['rows']) >= 3 or c in first or r['coverage'].startswith('COVERED') or int(r['probe_cases']) >= 40 or c >= 'N2379'}
open('pinwant.txt', 'w').write(' '.join(sorted(want)))
PY
for i in 0 1; do PART=$i/2 python3 "$DR/pinmulti.py" "$W" "$MAIN" "$OBJRANK" "$SCX" "$G1" "$W/dumps" "$W/pdumps" "$W/pmtmp_$i" "$W/pins_multi_$i.txt" $(cat pinwant.txt) > pinmulti_$i.log 2>&1 & done; wait
cat pins_multi_0.txt pins_multi_1.txt > pins_new.txt
python3 "$DR/sites.py" pins_new.txt sites_new.json "$REPO/src"
# residue cases named by the pass READMEs -> the map's ids (drivers/casekeys.sh; evidence/residue_cases.txt)
( cd "$REPO/tools/probe" && for c in r11u133repro/lhs/l01_hdr_int r11u133repro/lhs/l07_body_ctl r11u133repro/lhs/l09_iface_hdr r11u133repro/lhs/l11_hdr_two_inst r11u133repro/lhs/l04_hdr_unpacked r11u133repro/tix/t14 r11u133repro/tix/t08 r11v133repro/tix/a02_gen_for r11v133repro/tix/f06_gen_if r11v133repro/tix/a07_hier_idx r11u133repro/pkr/p01 r11u133repro/pkr/u01; do "$DR/casekeys.sh" "$PWD/$c" $(echo $c | tr / _) | tail -1; done ) > residue_cases.txt
cp "$DR/../evidence/residue_routes.json" residue_routes.json
python3 "$DR/mksites.py" pins_new.txt sites_new.json "$REPO/tools/probe/r11u138map" "$DR/../evidence/decoded_sites.json" sites.json
# 4. the net-binding law MEASURED: a full sweep with NB, its STRICT_NOTEQUAL rows analysed the same way
( cd "$REPO" && SLANG_UHDM=$NB tests/sweep.sh --jobs 3 --workdir /tmp/r11u142_nbwd --corpus "probe surelog uhdm2rtlil" > /tmp/r11u142_nbsweep.log 2>&1 ) || true
WN=/tmp/r11u142_worknb; mkdir -p $WN/tmp; ( cd $WN
  python3 "$DR/jobs.py" /tmp/r11u142_nbwd/surelog.csv /tmp/r11u142_nbwd/uhdm2rtlil.csv /tmp/r11u142_nbwd jobs_int.tsv
  DUMPS=$WN/dumps awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WN/dumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WN/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl $WN/dumps 3
  python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('/tmp/r11u142_nbwd/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/r11u142_nbwd/probe/'+n+'.uhdm',rel])+'\n')"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WN/pdumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WN/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl $WN/pdumps 3 )
# 4b. pass 137 (6ef15be0) landed during the measurement: the same cross-section from a 6ef15be0 worktree build P137
( cd /tmp/wt_r11u142p137 && SLANG_UHDM=$P137 tests/sweep.sh --jobs 3 --workdir /tmp/r11u142_p137wd --corpus "probe surelog uhdm2rtlil" > /tmp/r11u142_p137sweep.log 2>&1 ) || true
WP=/tmp/r11u142_workp137; mkdir -p $WP/tmp; ( cd $WP
  python3 "$DR/jobs.py" /tmp/r11u142_p137wd/surelog.csv /tmp/r11u142_p137wd/uhdm2rtlil.csv /tmp/r11u142_p137wd jobs_int.tsv
  awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | DUMPS=$WP/dumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WP/tmp python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl $WP/dumps 3
  python3 -c "
import csv
P={r['case']:r for r in csv.DictReader(open('/tmp/r11u142_p137wd/probe.csv'))}
with open('probe_ne.tsv','w') as f:
    for l in open('$W/probejobs.tsv'):
        c,m,n,g,o,rel=l.rstrip('\n').split('\t')
        if P[rel]['status']=='STRICT_NOTEQUAL': f.write('\t'.join([c,m,n,g,'/tmp/r11u142_p137wd/probe/'+n+'.uhdm',rel])+'\n')"
  awk -F'\t' '{print $1,$2,$3,$4,$5}' probe_ne.tsv | DUMPS=$WP/pdumps xargs -P3 -n5 "$DR/run1.sh"
  R11U138_TMP=$WP/tmp python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl $WP/pdumps 3 )
# 5. tables
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final.txt
python3 "$DR/report.py" "$W" "$W/out" > report.txt
python3 "$DR/extra.py" "$W" "$W/out" > extra.txt
python3 "$DR/structural.py" "$W/out" > structural.txt
python3 "$DR/afternb.py" "$W" "$WN" "$W/out" /tmp/r11u142_nbwd > afternb.txt     # merges the after-nb columns
AFTER_TAG=p137 python3 "$DR/afternb.py" "$W" "$WP" "$W/out" /tmp/r11u142_p137wd > afterp137.txt
python3 "$DR/mdtables.py" "$W" "$W/out" > mdtables.txt
python3 - <<'PY' > evwant.txt
import csv
w = set(open('pinwant.txt').read().split()) | {r['cluster_id'] for r in csv.DictReader(open('out/cluster_index.csv')) if int(r['rows']) >= 4}
print(' '.join(sorted(w)))
PY
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat evwant.txt)
python3 "$DR/rowobjects.py" "$W" "$W/row_objects.csv"
# 6. the deliverable (this directory); no artifact spells a slang-fenced name; the tests/probe grid dir is written cases/
M=$DR/..
cp out/clusters.csv out/probe_clusters.csv out/fail_list.csv out/probe_fail_list.csv out/cluster_index.csv out/family_index.csv "$M/"
rm -rf "$M/evidence/clusters"; cp -r ev/clusters "$M/evidence/"
cp ev/objects.csv row_objects.csv final.txt extra.txt report.txt structural.txt afternb.txt afterp137.txt mdtables.txt pins_new.txt sites.json pinwant.txt residue_cases.txt "$M/evidence/"
python3 "$DR/redact.py" "$REPO" "$M"
( cd "$M" && grep -rl '/cases/\|__cases__' . | grep -v '^./drivers/' | while read f; do sed -i 's#/cases/#/cases/#g; s#__cases__#__cases__#g' "$f"; done )
python3 "$DR/delta.py" "$REPO" "$M" > "$M/evidence/delta.txt"
python3 "$DR/readme_tables.py" "$M" > readme_tables.md   # the README's tables (sections open / covered / first)
