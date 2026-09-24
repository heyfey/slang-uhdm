#!/bin/bash
# B1: the UVM order coin (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard). Runs the
# four tests N times (both modes, fresh workdirs), records each run's status and
# strict verdict and the md5 of our database: the coin must have FIRED (two
# md5s for one row-mode) for the status stability to mean anything.
# Usage: <repo> <workdir-prefix> <N>
set -u; R=$1; P=$2; N=$3
for i in $(seq 1 $N); do
  rm -rf $P$i; python3 $R/scripts/verify_golden.py --corpus surelog --mode both --jobs 3 \
    --filter '^(MiniAmiq|SeqDriver|SimpleUVM|Scoreboard)$' --out $P$i.csv --workdir $P$i > /dev/null
  for d in $P$i/*/*/; do m=$(basename $(dirname $d)); t=$(basename $d); t=${t%-*}
    echo "run=$i $t $m $(grep "^$t,$m," $P$i.csv | cut -d, -f3,6) md5=$(md5sum < $d/slang.uhdm 2>/dev/null | cut -c1-12)"; done
done | sort -k2,3 -k1,1
