#!/bin/bash
# classify_corpus.sh <bvfile> <pris mirror corpus root> <law mirror corpus root> <pris sweep corpus root>: classify each mover
source $(dirname $0)/env.sh
[ $(echo $FENCED | wc -w) -eq 4 ] || { echo "REFUSE: FENCED unset"; exit 9; }
re=$(echo $FENCED | tr ' ' '|')
grep '^MOVER ' $1 | awk '{print $2}' | grep -v -w -E "($re)" | while read p; do
  d=$(dirname $p); c=$(grep -o 'goldens/[0-9a-f]*' $4/$d/cmds.txt | head -1)
  g=$HOME/.cache/slang-uhdm-goldens/${c#goldens/}/golden.uhdm
  [ -s $g ] || { echo "$d NOGOLD"; continue; }
  echo "$d: $(timeout 600 python3 $(dirname $0)/unmask.py $g $2/$p $3/$p | head -3 | tr '\n' ' ' | cut -c1-400)"
done
