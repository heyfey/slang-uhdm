#!/bin/bash
# (copy of r11u175uvm/drivers/uvmcensus_sweep.sh with this pass's paths; the census and family scripts are r11u175's, read in place)
# uvmcensus_sweep.sh <sweep workdir> <out dir>: the r11u172 UVM census (map 8's analyzer and keys) over the five
# UVM rows' DEFAULT databases of an existing gate sweep (<wd>/surelog/default/<test>-<hash>/{slang.uhdm,cmds.txt}).
# None of the five rows is slang-fenced (checked by name against $FENCED, fail closed).
set -u; : "${FENCED:?FENCED unset}"
W=$1; O=$2; D=/tmp/wt_r11u176/tools/probe/r11u175uvm/drivers; MAP=/tmp/wt_r11u176/tools/probe/r11u165map
T='BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM'
for t in $T; do for f in $FENCED; do [ "$t" = "$f" ] && { echo "fenced row in list"; exit 3; }; done; done
mkdir -p $O; : > $O/jobs_def.tsv
for t in $T; do d=$(ls -d $W/surelog/default/$t-* | head -1); [ -s $d/slang.uhdm ] || continue
  g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')
  st=$(grep "^$t,default," $W/surelog.csv | cut -d, -f6)
  printf 'surelog\tdefault\t%s\t%s\t%s\t%s\n' $t $g/golden.uhdm $d/slang.uhdm "$st" >> $O/jobs_def.tsv; done
awk -F'\t' '{print $1,$2,$3,$4,$5}' $O/jobs_def.tsv | SCMP=/tmp/r11u176_bin/strictcmp_x DUMPS=$O/dumps xargs -P3 -n5 bash $MAP/drivers/run1.sh
R11U138_TMP=$O/tmp python3 $MAP/drivers/analyze.py $O/jobs_def.tsv $O/ana.jsonl $O/dumps 3
python3 $D/uvmcensus.py $O/ana.jsonl $MAP/cluster_index.csv $O/census > /dev/null
python3 $D/uvmfamilies.py $O/census_rank.csv $O/families.txt
python3 -c "
import json
for l in open('$O/ana.jsonl'):
    r=json.loads(l); print(r['test'], 'verify_ok=%s' % r['verify']['ok'], r['verify']['tool_first'], r['verify']['ndiff'])"
