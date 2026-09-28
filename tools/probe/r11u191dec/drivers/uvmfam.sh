#!/bin/bash
# r11u191: r11u175's UVM family census (r11u175uvm/drivers/uvmcensus.py + uvmfamilies.py, map 8's cluster_index.csv as
# the key table, as r11u189map/drivers/uvmcensus9.sh runs it) over the five UVM rows' DEFAULT databases of one
# analyze.py jsonl.  usage: uvmfam.sh <analyze.jsonl> <out dir>      (none of the five rows is fenced: checked)
set -eu; D=$(cd "$(dirname "$0")" && pwd); MAP8=$D/../../r11u165map; U=$D/../../r11u175uvm/drivers
F=$(python3 -c "import sys; sys.path.insert(0,'$D'); import common; print(' '.join(sorted(common.fenced())))")
T='BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM'
for t in $T; do for f in $F; do [ "$t" = "$f" ] && { echo "fenced row in list"; exit 3; }; done; done
mkdir -p $2
python3 -c "
import json
T=set('$T'.split())
with open('$2/ana_uvm.jsonl','w') as o:
    for l in open('$1'):
        r=json.loads(l)
        if r['test'] in T and r['mode']=='default': o.write(l)
"
python3 $U/uvmcensus.py $2/ana_uvm.jsonl $MAP8/cluster_index.csv $2/census > /dev/null
python3 $U/uvmfamilies.py $2/census_rank.csv $2/families.txt
