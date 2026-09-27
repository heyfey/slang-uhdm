#!/bin/bash
# usage: vjoin.sh <gridA.txt> <gridB.txt> [tagA=pris] [tagB=law]
# vjoin.sh <pris-grid.txt> <law-grid.txt>: per case-mode, pristine vs law verdicts, bytes, record movement (r11u184's recmv.py)
D=$(cd "$(dirname "$0")" && pwd); TA=${3:-pris}; TB=${4:-law}
R=$D/../../r11u184repro/drivers
declare -A P
while read rel tag rest; do P[$rel]="$rest"; done < $1
while read rel tag rest; do
  p="${P[$rel]}"; w=/tmp/v11u184_g/$rel
  ps=$(echo "$p" | grep -o 'strict=[^ ]*\|SURELOG_FAIL\|SLANG_FAIL' | head -1); ls=$(echo "$rest" | grep -o 'strict=[^ ]*\|SURELOG_FAIL\|SLANG_FAIL' | head -1)
  pc=$(echo "$p" | grep -o 'cmplines=[0-9]*'); lc=$(echo "$rest" | grep -o 'cmplines=[0-9]*')
  pm=$(echo "$p" | grep -o 'md5=.*'); lm=$(echo "$rest" | grep -o 'md5=.*')
  mv=$(python3 $R/recmv.py $w/$TA.strict $w/$TB.strict 2>/dev/null | head -1)
  ob=$(python3 $D/vobdist.py $w/gold/golden.dump $w/$TA.dump $w/$TB.dump 2>/dev/null | tail -1)
  fires=$(grep -o 'R11U184 law [A-Za-z ]*' $w/$TB.log 2>/dev/null | sort | uniq -c | awk '{printf "%s:%s ", $4$5, $1}')
  echo "$rel | $pc $ps -> $lc $ls | $([ "$pm" = "$lm" ] && echo SAME || echo MOVED) | $mv | ob $ob | $fires"
done < $2
