#!/bin/bash
# corpusdist.sh <moverlist> <corpus> <newroot> <oldroot> : order-blind distance to golden per mover (fence-aware)
. /tmp/v11u152_env.sh
[ -n "$FENCED" ] || { echo "FENCED unset: refusing"; exit 2; }
F=$(echo $FENCED | tr ',' '|')
while read p; do
  echo "$p" | grep -qwE "$F" && { echo "SKIP_FENCED"; continue; }
  d=$(dirname $p); g=$(grep -o 'golden cache hit [^)]*' $3/$2/$d/cmds.txt | awk '{print $4}')/golden.uhdm
  [ -s "$g" ] || { echo "$d NO_GOLDEN"; continue; }
  echo "$d $(python3 /tmp/v11u152_drv/dumpdist.py $g $4/$2/$p $3/$2/$p)"
done < $1
