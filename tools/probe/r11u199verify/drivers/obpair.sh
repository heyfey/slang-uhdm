#!/bin/bash
# obpair.sh <wdA> <wdB> <corpus> <mode> <row>...: order-blind uhdm-dump difference of each row-mode between two sweep
# workdirs (the workdir prefix normalised, sorted, comm -3 line count) and the differing lines (at most 8).
# Refuses fenced rows (fail-closed on $FENCED).
source "$(dirname "$0")/env.sh" || exit 2
A=$1; B=$2; C=$3; M=$4; shift 4; T=/tmp/r11u199_ob; mkdir -p $T
for R in "$@"; do
  echo "$R" | grep -Pq "$FENCE_RE" && { echo "$R fenced: refused"; continue; }
  da=$(ls -d $A/$C/$M/$R-* | head -1); db=$(ls -d $B/$C/$M/$R-* | head -1)
  $UHDM_DUMP $da/slang.uhdm 2>/dev/null | sed "s#$A##g" | LC_ALL=C sort > $T/a; $UHDM_DUMP $db/slang.uhdm 2>/dev/null | sed "s#$B##g" | LC_ALL=C sort > $T/b
  n=$(LC_ALL=C comm -3 $T/a $T/b | wc -l)
  echo "$C/$M/$R md5 $(md5sum < $da/slang.uhdm | cut -c1-10)/$(md5sum < $db/slang.uhdm | cut -c1-10) orderblind_lines=$n"
  LC_ALL=C comm -3 $T/a $T/b | head -8 | sed 's/^/    /' | cut -c1-160
done
