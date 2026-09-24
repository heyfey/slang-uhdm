#!/bin/bash
# r11u142: the map's cluster ids of a residue case named by a pass README (a dut.sv dir outside tests/probe).
# Golden: the pinned Surelog with check_probe's flags; ours: the frozen exporter with check_probe's flags;
# strictcmp_x --max 50 record dumps; analyze.py's key + common.rekey -> the map's id (ids.json) or NEW.
# usage: casekeys.sh <case dir> <tag>   env: SURELOG SLANG_UHDM SCX W (ids.json in W)
set -u
d=$1; t=$2; o=/tmp/r11u142_cases/$t; rm -rf "$o"; mkdir -p "$o/gold" "$o/dumps/case/default"
DR=$(cd "$(dirname "$0")" && pwd)
( cd "$d" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$o/gold" > "$o/surelog.log" 2>&1 )
g=$(find "$o/gold" -name '*.uhdm' | head -1)
( cd "$d" && "$SLANG_UHDM" dut.sv --single-unit --nobuiltin -o "$o/ours.uhdm" > "$o/slang.log" 2>&1 )
[ -n "$g" ] && [ -s "$o/ours.uhdm" ] || { echo "$t NODB"; exit 0; }
"$UHDM_CMP" "$g" "$o/ours.uhdm" > "$o/cmp.txt" 2>&1; ncmp=$(wc -l < "$o/cmp.txt")
"$SCX" --max 50 --dump-a "$o/dumps/case/default/$t.a" --dump-b "$o/dumps/case/default/$t.b" "$g" "$o/ours.uhdm" > "$o/dumps/case/default/$t.out" 2>&1; echo "rc=$?" >> "$o/dumps/case/default/$t.out"
v=$(grep -o '^\(STRICT_[A-Z_]*\|NOT_EQUAL\) [^ ]*' "$o/dumps/case/default/$t.out" | head -1)
printf 'case\tdefault\t%s\t%s\t%s\t-\n' "$t" "$g" "$o/ours.uhdm" > "$o/job.tsv"
if grep -q '^rc=2' "$o/dumps/case/default/$t.out"; then
  R11U138_TMP=$o python3 "$DR/analyze.py" "$o/job.tsv" "$o/a.jsonl" "$o/dumps" 1
  python3 - "$o/a.jsonl" "$W/ids.json" "$t" "$ncmp" "$v" <<'PY'
import json, sys, collections
sys.path.insert(0, '/tmp/wt_r11u142/tools/probe/r11u142map/drivers'); from common import rekey
r = json.loads(open(sys.argv[1]).read()); cid = json.load(open(sys.argv[2]))['cid']
n = collections.Counter(); first = None
for x in r['rows']:
    c = rekey(x); n[cid.get(c, 'NEW:' + c)] += 1
    p = x['ia'] if x['ia'] >= 0 else x['ib']
    if first is None or p < first[0]: first = (p, cid.get(c, 'NEW:' + c))
print(sys.argv[3], f'cmp={sys.argv[4]}', sys.argv[5], 'first=' + (first[1] if first else '-'), ' '.join(f'{k}:{v}' for k, v in n.most_common()))
PY
else echo "$t cmp=$ncmp $v"; fi
