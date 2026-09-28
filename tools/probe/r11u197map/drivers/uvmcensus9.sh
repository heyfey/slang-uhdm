#!/bin/bash
# uvmcensus9.sh <analyze.jsonl of a sweep's fail rows> <out dir>: r11u175's UVM census (its uvmcensus.py +
# uvmfamilies.py, map 8's cluster_index.csv as the key table, so the F1-F9 families are r11u175's) over the five UVM
# rows' DEFAULT databases, read from the map's own analyzer output (the same analyze.py and strictcmp_x record
# dumps r11u175's uvmcensus_sweep.sh used). None of the five rows is slang-fenced (checked, fail closed).
set -eu; D=$(cd "$(dirname "$0")" && pwd); MAP8=$D/../../r11u165map
F=$(python3 -c "import sys; sys.path.insert(0,'$D'); import common; print(' '.join(sorted(common.fenced())))")
T='BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM'
for t in $T; do for f in $F; do [ "$t" = "$f" ] && { echo "fenced row in list"; exit 3; }; done; done
mkdir -p $2
python3 -c "
import json,sys
T=set('$T'.split())
with open('$2/ana_uvm.jsonl','w') as o:
    for l in open('$1'):
        r=json.loads(l)
        if r['test'] in T and r['mode']=='default': o.write(l)
"
python3 $D/uvmcensus.py $2/ana_uvm.jsonl $MAP8/cluster_index.csv $2/census > /dev/null
python3 $D/uvmfamilies.py $2/census_rank.csv $2/families.txt
head -12 $2/families.txt
