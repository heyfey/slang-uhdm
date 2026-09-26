#!/bin/bash
# switches.sh <pristine> <law> <case dir>...: R11U175_OFF=1 on the law binary must write the pristine bytes
# (md5 of the database) on every case; prints SAME/DIFF per case and a tally. Fail-closed on $FENCED.
set -u; : "${FENCED:?FENCED unset}"
P=$1; L=$2; shift 2; T=/tmp/r11u175_scratch/sw; mkdir -p $T; same=0; diff=0
for c in "$@"; do
  for f in $FENCED; do echo "$c" | grep -qw "$f" && { echo "$c fenced: refused"; continue 2; }; done
  rm -f $T/p.uhdm $T/l.uhdm
  (cd $c && timeout 300 $P dut.sv --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1)
  (cd $c && R11U175_OFF=1 timeout 300 $L dut.sv --single-unit --nobuiltin -o $T/l.uhdm >/dev/null 2>&1)
  if [ "$(md5sum < $T/p.uhdm)" = "$(md5sum < $T/l.uhdm)" ]; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $c"; fi
done
echo "switch R11U175_OFF: SAME=$same DIFF=$diff"
