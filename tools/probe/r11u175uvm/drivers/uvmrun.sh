#!/bin/bash
# uvmrun.sh <binary> <outdir>: the five UVM rows (BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM), both modes,
# through scripts/verify_golden.py (--filter; none of the five is slang-fenced, checked by name against $FENCED),
# then strictcmp_x record dumps + map 8's analyzer on the default rows, then the census (uvmcensus/uvmfamilies).
set -u
: "${FENCED:?FENCED unset}"
BIN=$1; W=$2; D=$(cd "$(dirname "$0")" && pwd); MAP=/home/heyfey/git-repos/slang-uhdm/tools/probe/r11u165map
T='BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM'
for t in $T; do for f in $FENCED; do [ "$t" = "$f" ] && { echo "fenced row in list"; exit 3; }; done; done
mkdir -p $W; cd /tmp/wt_r11u175
SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "^($(echo $T | tr ' ' '|'))\$" --out $W/sl.csv --workdir $W/wd > $W/log 2>&1
grep -h '^slang:' $W/wd/*/*/cmds.txt | awk '{print $2}' | sort | uniq -c
: > $W/jobs_def.tsv
for d in $W/wd/default/*/; do t=$(basename $d); t=${t%-*}; [ -s $d/slang.uhdm ] || continue
  g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}'); st=$(grep "^$t,default," $W/sl.csv | cut -d, -f6)
  printf 'surelog\tdefault\t%s\t%s\t%s\t%s\n' $t $g/golden.uhdm ${d}slang.uhdm $st >> $W/jobs_def.tsv; done
awk -F'\t' '{print $1,$2,$3,$4,$5}' $W/jobs_def.tsv | SCMP=/tmp/r11u175_bin/strictcmp_x DUMPS=$W/dumps xargs -P3 -n5 bash $MAP/drivers/run1.sh
R11U138_TMP=$W/tmp python3 $MAP/drivers/analyze.py $W/jobs_def.tsv $W/ana.jsonl $W/dumps 3
python3 $D/uvmcensus.py $W/ana.jsonl $MAP/cluster_index.csv $W/census > /dev/null
python3 $D/uvmfamilies.py $W/census_rank.csv $W/families.txt
cat $W/sl.csv
