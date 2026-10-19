#!/bin/bash
# away.sh <ctl svtests work> <new svtests work> : rows kept in both; golden from the cache dir named in cmds.txt;
# normalised dump distance to golden before/after (diff line count)
source /tmp/v11u406_env.sh
C=$1; N=$2; T=/tmp/v11u406_aw.$$
norm() { $UHDM_DUMP $1 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//; s#/tmp/[a-z0-9_]+/svtests/work/##g'; }
cd $C
for f in $(find . -name slang.uhdm | sort); do
  d=$(dirname $f); [ -f $N/$d/slang.uhdm ] || { echo "$d GONE"; continue; }
  g=$(grep -o 'golden cache hit [^)]*' $N/$d/cmds.txt | awk '{print $4}')/golden.uhdm
  [ -f "$g" ] || g=$N/$d/slpp_all/surelog.uhdm
  [ -f "$g" ] || { echo "$d NOGOLDEN"; continue; }
  norm $C/$d/slang.uhdm > $T.c; norm $N/$d/slang.uhdm > $T.n
  if cmp -s $T.c $T.n; then echo "$d same-dump"; continue; fi
  norm $g > $T.g
  a=$(diff $T.g $T.c | grep -c '^[<>]'); b=$(diff $T.g $T.n | grep -c '^[<>]')
  read x ma y mb <<< "$(python3 /tmp/v11u406_scr/msdist.py $T.g $T.c $T.n | tr '\n' ' ')"
  if [ $mb -lt $ma ]; then t=TOWARD; elif [ $mb -gt $ma ]; then t=AWAY; else t=SAMEDIST; fi
  echo "$d $t multiset $ma -> $mb diff $a -> $b"
done
rm -f $T.*
