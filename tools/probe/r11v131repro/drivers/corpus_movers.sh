#!/usr/bin/env bash
# corpus_movers.sh <wdNew> <wdOld> <corpus> : for each byte mover, firstdiff + fieldworse vs golden
N=$1; O=$2; C=$3
grep '^MOVER' /tmp/v11u131_bv_cur_$C.txt | awk '{print $2}' | while read p; do
  d=$(dirname $p); gd=$(grep -o 'golden cache hit [^)]*' $N/$C/$d/cmds.txt | awk '{print $4}')
  g=$(ls $gd/*.uhdm 2>/dev/null | head -1)
  [ -z "$g" ] && { echo "$C/$d NOGOLDEN"; continue; }
  echo "$C/$d $(python3 /tmp/v11u131_drv/firstdiff.py $g $O/$C/$p $N/$C/$p) || $(python3 /tmp/v11u131_drv/fieldworse.py $g $O/$C/$p $N/$C/$p | cut -c1-200)"
done
