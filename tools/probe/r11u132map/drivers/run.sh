#!/bin/bash
# The r11u132 map pipeline (measurement only). Inputs: a strict sweep workdir SW
# (tests/sweep.sh --workdir SW with SLANG_UHDM and STRICT_CMP exported to frozen
# binaries) holding <corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt},
# <corpus>.csv and probe/<rel with / -> __>.uhdm. W = scratch work dir.
# Env: SW W SCX (drivers/strictcmp_x.cpp built by cc.sh) OBJRANK G1 (the exporter
# built with -g1 line tables, for site pinning), plus the pinned tool variables.
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd)
: "${SW:?}" "${W:?}" "${SCX:?}" "${OBJRANK:?}" "${G1:?}"
mkdir -p "$W"; cd "$W"; export R11U132_TMP=$W/tmp SCMP=$SCX
python3 "$DR/jobs.py" "$SW/surelog.csv" "$SW/uhdm2rtlil.csv" "$SW" jobs_int.tsv
DUMPS=$W/dumps; export DUMPS
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | xargs -P2 -n5 "$DR/run1.sh"
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" "$SW/probe" "$W/probejobs.tsv" && python3 "$DR/probelaw.py" ) > probe_law.tsv
DUMPS=$W/pdumps; export DUMPS
awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | xargs -P3 -n5 "$DR/run1.sh"
: > probe_ne.tsv; : > probe_verdict.tsv
while IFS=$'\t' read c m n g o rel; do f=$W/pdumps/probe/default/$n.out
  if grep -q '^rc=2' "$f"; then printf '%s\t%s\t%s\t%s\t%s\t%s\n' $c $m $n $g $o $rel >> probe_ne.tsv
    printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $f | cut -d' ' -f2)" >> probe_verdict.tsv; fi
done < probejobs.tsv
python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 2
python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
echo '{}' > sites.json
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final0.txt   # ids.json
# pin: the first cluster of every failing row, every cluster with >= 8 rows, the covered ones, >= 40 probe cases
python3 - <<'PY' > pinwant.txt
import csv
R = list(csv.DictReader(open('out/cluster_index.csv'))); fl = list(csv.DictReader(open('out/fail_list.csv')))
w = {r['first_cluster'] for r in fl} | {r['cluster_id'] for r in R if int(r['rows']) >= 8 or r['coverage'].startswith('COVERED') or int(r['probe_cases']) >= 40}
print(' '.join(sorted(w)))
PY
( cd "$REPO" && python3 "$DR/pinprep2.py" "$W" "$REPO" "$OBJRANK" "$SCX" "$W/dumps" "$W/pdumps" "$W/pin2tmp" $(cat "$W/pinwant.txt") ) > pinprep2.tsv
split -n l/4 -d pinprep2.tsv pin2chunk_
for i in 00 01 02 03; do MAXR=1 python3 "$DR/pinall.py" pin2chunk_$i "$G1" "$REPO/src" pins2_$i.txt & done; wait
cat pins2_0*.txt > pins.txt; python3 "$DR/sites.py" pins.txt sites.json "$REPO/src"; cp "$DR/../evidence/decoded_sites.json" .
python3 - <<'PY'
import json; s = json.load(open('sites.json')); d = json.load(open('decoded_sites.json')) if __import__('os').path.exists('decoded_sites.json') else {}
for k, v in d.items(): s.setdefault(k, {}).update(v)
json.dump({k: (v['site'] + (' [' + v['note'] + ']' if v.get('note') else '')) for k, v in s.items()}, open('sites.json', 'w'), indent=1)
PY
python3 "$DR/final.py" "$W" "$REPO" "$W/out" "$SW" > final.txt
python3 "$DR/extra.py" "$W" "$W/out" > extra.txt
python3 "$DR/evid.py" "$W" "$W/dumps" "$W/pdumps" "$W/ev" $(cat "$W/pinwant.txt")
python3 "$DR/rowobjects.py" "$W" "$W/row_objects.csv"
