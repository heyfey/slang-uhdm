#!/bin/bash
# firstdiff.sh <csvA> <csvB> <wdA> <wdB> <corpus> : for each changed STRICT row, first-diff index/field A vs B
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "export FENCED (the four slang-fenced names) first"; exit 1; }
python3 /tmp/v11u146_colcmp.py $1 $2 2>/dev/null | while read key rest; do
  n=${key%/*}; m=${key#*/}
  for f in $FENCED; do [ "$n" = "$f" ] && continue 2; done
  echo "$rest" | grep -q "CMP_EQUAL', 'equal') *$" && [ "$(echo "$rest" | grep -o "'CMP_EQUAL'" | wc -l)" = 1 ] && echo "$rest" | grep -q -- "-> ('CMP_EQUAL'" && { echo "$key CONVERSION"; continue; }
  da=$(ls -d $3/$5/$m/$n-* 2>/dev/null | head -1); db=$(ls -d $4/$5/$m/$n-* 2>/dev/null | head -1)
  g=$(grep -o 'golden cache hit [^)]*' $da/cmds.txt | awk '{print $4}')/golden.uhdm; [ -f "$g" ] || { g=$(find $da -name '*.uhdm' ! -name slang.uhdm | head -1); }
  [ -f "$g" ] || { echo "$key NOGOLDEN"; continue; }
  ra=$(timeout 600 /tmp/v11u146_bin/uhdm-strictcmp --max 1 $g $da/slang.uhdm 2>&1 | grep -m1 -A2 '^#'); rb=$(timeout 600 /tmp/v11u146_bin/uhdm-strictcmp --max 1 $g $db/slang.uhdm 2>&1 | grep -m1 -A2 '^#')
  ia=$(echo "$ra" | head -1 | awk '{print $1}' | tr -d '#'); ib=$(echo "$rb" | head -1 | awk '{print $1}' | tr -d '#')
  v=SAME; [ "$ia" -lt "$ib" ] 2>/dev/null && v=LATER; [ "$ia" -gt "$ib" ] 2>/dev/null && v=EARLIER
  [ "$v" = SAME ] && [ "$(echo "$ra" | tail -1)" != "$(echo "$rb" | tail -1)" ] && v=SAME_INDEX_DIFFERENT_RECORD
  echo "$key A#$ia B#$ib $v $rest"
done
