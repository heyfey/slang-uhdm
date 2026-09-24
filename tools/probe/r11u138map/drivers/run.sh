#!/bin/bash
# The r11u138 map pipeline (measurement only). r11u132map's pipeline (drivers copied, adapted)
# on the READ-ONLY e562f4d4 reference sweep SW=/tmp/intr11u136 (<corpus>/<mode>/<test>-<hash>/
# {slang.uhdm,cmds.txt}, <corpus>.csv, probe/<rel with / -> __>.uhdm), whose status and strict
# columns equal results/golden_*.csv row for row. W = scratch work dir.
# Env: SW W SCX (drivers/strictcmp_x.cpp built by cc.sh) OBJRANK G1 (the exporter built with
# -g1 line tables) + SURELOG SURELOG_ROOT UHDM2RTLIL_TESTS (the pins; probe cache keys read
# Surelog's version line).
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd); RES=$REPO/results
: "${SW:?}" "${W:?}" "${SCX:?}" "${OBJRANK:?}" "${G1:?}"
mkdir -p "$W"; cd "$W"; export R11U138_TMP=$W/tmp SCMP=$SCX
# 1. jobs: every STRICT_NOTEQUAL row-mode of the committed baselines, databases from SW
python3 "$DR/jobs.py" "$RES/golden_surelog.csv" "$RES/golden_uhdm2rtlil.csv" "$SW" jobs_int.tsv
DUMPS=$W/dumps; export DUMPS
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | xargs -P3 -n5 "$DR/run1.sh"
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" "$SW/probe" "$W/probejobs.tsv" && python3 "$DR/probelaw.py" ) > probe_law.tsv
DUMPS=$W/pdumps; export DUMPS
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | xargs -P2 -n5 "$DR/run1.sh"
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
# 3. pins: round 1 = pinprep2 + pinall (one gdb run per cluster) on the r11u132map set
#    (first cluster of every failing row, >= 8 rows, covered, >= 40 probe cases); round 2 = pinmulti
#    (one gdb run per example row, every other cluster). Round 1 was stopped after 265 complete
#    entries; pinmulti pinned the remaining 2100 (it reproduces round 1's frames exactly, 4 of 4 checked).
python3 - <<'PY' > pinwant.txt
import csv
R = list(csv.DictReader(open('out/cluster_index.csv'))); fl = list(csv.DictReader(open('out/fail_list.csv')))
w = {r['first_cluster'] for r in fl} | {r['cluster_id'] for r in R if int(r['rows']) >= 8 or r['coverage'].startswith('COVERED') or int(r['probe_cases']) >= 40}
print(' '.join(sorted(w)))
PY
( cd "$REPO" && python3 "$DR/pinprep2.py" "$W" "$REPO" "$OBJRANK" "$SCX" "$W/dumps" "$W/pdumps" "$W/pin2tmp" $(cat "$W/pinwant.txt") ) > pinprep2.tsv
split -n l/3 -d pinprep2.tsv pin2chunk_
for i in 00 01 02; do MAXR=1 python3 "$DR/pinall.py" pin2chunk_$i "$G1" "$REPO/src" pins2_$i.txt & done; wait
python3 - <<'PY'
import re, json
done = set(); keep = []
for i in ('00', '01', '02'):
    for e in re.split(r'(?m)^(?===)', open(f'pins2_{i}.txt').read()):
        if e.strip() and re.search(r'#\d+ \S+ at \S+\.cpp:\d+', e): keep.append(e); done.add(e.split()[1])
open('pins_round1.txt', 'w').write(''.join(keep))
cid = json.load(open('ids.json'))['cid']
open('pinwant_multi.txt', 'w').write(' '.join(sorted(v for v in cid.values() if v not in done)))
PY
for i in 0 1 2; do PART=$i/3 python3 "$DR/pinmulti.py" "$W" "$REPO" "$OBJRANK" "$SCX" "$G1" "$W/dumps" "$W/pdumps" "$W/pmtmp_$i" "$W/pins_multi_$i.txt" $(cat "$W/pinwant_multi.txt") > pinmulti_$i.log 2>&1 & done; wait
# The partition that drew Earlgrey_0_1/testflags (594 clusters in one row) was OOM-killed (15 GB host, python
# holding the 1.3M-record dump): its gdb script had saved 545 of 593 ranks -> pinrecover.py (548 clusters);
# the partition's other rows were re-run alone; the 46 Earlgrey-only clusters left are NOT PINNED.
python3 "$DR/pinrecover.py" pmtmp_2 surelog/testflags/Earlgrey_0_1 pins_recovered_earlgrey.txt
cat pins_round1.txt pins_multi_*.txt pins_recovered_earlgrey.txt | grep '^==' | awk '{print $2}' | sort -u > pinned_ids.txt
python3 - "$DR" <<'PY'
import json, sys
sys.path.insert(0, sys.argv[1]); from common import rekey
cid = json.load(open('ids.json'))['cid']; done = set(open('pinned_ids.txt').read().split()); want = set(cid.values()) - done; best = {}
for src in ('corpus', 'probe'):
    for l in open(f'{src}.jsonl'):
        r = json.loads(l)
        for x in r['rows']:
            k = cid.get(rekey(x))
            if k in want and (k not in best or (r['nB'], r['mode'] != 'default') < best[k][0]): best[k] = ((r['nB'], r['mode'] != 'default'), r['test'])
eg = sorted(k for k, v in best.items() if v[1] == 'Earlgrey_0_1')
open('pinwant_rest.txt', 'w').write(' '.join(sorted(k for k in want if k not in eg))); open('unpinned_earlgrey.txt', 'w').write(' '.join(eg))
PY
python3 "$DR/pinmulti.py" "$W" "$REPO" "$OBJRANK" "$SCX" "$G1" "$W/dumps" "$W/pdumps" "$W/pmtmp_r" "$W/pins_multi_rest.txt" $(cat pinwant_rest.txt) > pinmulti_rest.log 2>&1
cat pins_round1.txt pins_multi_*.txt pins_recovered_earlgrey.txt | sed "s/ operator at / operator() at /" > pins.txt   # the first pinmulti runs wrote a lambda frame as `operator`
python3 "$DR/sites.py" pins.txt sites.json "$REPO/src"; cp "$DR/../evidence/decoded_sites.json" .
python3 - <<'PY'
import json; s = json.load(open('sites.json')); d = json.load(open('decoded_sites.json'))
for k, v in d.items(): s.setdefault(k, {}).update(v)
json.dump({k: (v.get('site', 'NOT PINNED') + (' [' + v['note'] + ']' if v.get('note') else '')) for k, v in s.items()}, open('sites.json', 'w'), indent=1)
PY
# 4. tables
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final.txt
python3 "$DR/extra.py" "$W" "$W/out" > extra.txt
python3 "$DR/report.py" "$W" "$W/out" > report.txt
python3 "$DR/structural.py" "$W/out" > structural.txt
python3 - <<'PY' > evwant.txt
import csv
w = set(open('pinwant.txt').read().split()) | {r['cluster_id'] for r in csv.DictReader(open('out/cluster_index.csv')) if int(r['rows']) >= 4}
print(' '.join(sorted(w)))
PY
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat "$W/evwant.txt")
python3 "$DR/rowobjects.py" "$W" "$W/row_objects.csv"
# 5. the deliverable (this directory), then no artifact spells a slang-fenced name
M=$DR/..
cp out/clusters.csv out/probe_clusters.csv out/fail_list.csv out/probe_fail_list.csv out/cluster_index.csv out/family_index.csv "$M/"
rm -rf "$M/evidence/clusters"; cp -r ev/clusters "$M/evidence/"
cp ev/objects.csv row_objects.csv final.txt extra.txt report.txt structural.txt pins.txt sites.json pinprep2.tsv pinwant.txt pinwant_multi.txt unpinned_earlgrey.txt "$M/evidence/"
python3 "$DR/redact.py" "$REPO" "$M"
# 6. as r11u132map did: the tests/probe grid directory `arms/` is written `cases/` in every artifact
#    (results/golden_probe.csv and tests/probe keep the real name: map `/cases/` back to `/arms/` to join)
( cd "$DR/.." && grep -rl '/arms/\|__arms__' . | grep -v '^./drivers/' | while read f; do sed -i 's#/arms/#/cases/#g; s#__arms__#__cases__#g' "$f"; done )
python3 "$DR/delta.py" "$REPO" "$DR/.." > "$DR/../evidence/delta.txt"
