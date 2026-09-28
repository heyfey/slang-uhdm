#!/bin/bash
# r11u206: order-blind reading of det.sh's draws.  For each binary and row-mode, dumps the three databases, removes
# the dump's path header and ids, and prints the distinct md5s of the SORTED dumps and, when they differ, the
# number of differing sorted lines between the first two distinct ones.  usage: detob.sh <det out root>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
R=$1
for b in $(ls $R); do for d in $(ls -d $R/$b/*.1 | sed 's/\.1$//'); do
  raw=$(for k in 1 2 3; do md5sum < $d.$k/slang.uhdm | cut -c1-10; done | sort -u | wc -l)
  [ "$raw" = 1 ] && { echo "$b $(basename $d) raw_hashes=1 (one database: no order-blind reading needed)"; continue; }
  for k in 1 2 3; do $UHDM_DUMP $d.$k/slang.uhdm 2>/dev/null | tail -n +2 | sed 's/, id:[0-9]*//g' | sort > $d.$k/ob.txt; done
  u=$(for k in 1 2 3; do md5sum < $d.$k/ob.txt | cut -c1-10; done | sort -u | tr '\n' ' ')
  n=0; if [ $(echo $u | wc -w) -gt 1 ]; then for k in 2 3; do c=$(diff $d.1/ob.txt $d.$k/ob.txt | grep -c '^[<>]'); [ $c -gt $n ] && n=$c; done; fi
  echo "$b $(basename $d) raw_hashes=$raw orderblind_hashes=$(echo $u | wc -w) max_orderblind_lines=$n"; rm -f $d.*/ob.txt
done; done
