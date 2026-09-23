#!/bin/bash
# cen112.sh <sweep-workdir> [calib]: per row (mode/name-hash dir holding slang.uhdm), the sig112
# signature of GOLDEN and OURS and the per-face delta (golden minus ours).  Prints only rows
# with a nonzero delta, plus a summary.  With "calib" the golden database is read as BOTH
# sides (calibration: must print 0 rows).
W=${1:?workdir}; MODE=${2:-}
SIG=${SIG:-/tmp/r11u112_bin/sig112}
export LD_LIBRARY_PATH=$HOME/.local/lib64
n=0; hit=0
for d in $(find "$W" -name cmds.txt -printf '%h\n' | sort); do
  [ -f "$d/slang.uhdm" ] || continue
  c=$(grep -o 'cache hit [^)]*' "$d/cmds.txt" | awk '{print $3}')
  if [ -n "$c" ]; then g="$c/golden.uhdm"; else g=$(ls "$d"/slpp_*/surelog.uhdm 2>/dev/null | head -1); fi
  [ -f "$g" ] || continue
  n=$((n+1))
  gs=$($SIG "$g"); if [ "$MODE" = calib ]; then ps=$($SIG "$g"); else ps=$($SIG "$d/slang.uhdm"); fi
  delta=$(paste -d' ' <(echo "$gs" | tr ' ' '\n') <(echo "$ps" | tr ' ' '\n') | awk -F'[ =]' '{d=$2-$4; if (d!=0) printf "%s%+d ", $1, d}')
  if [ -n "$delta" ]; then hit=$((hit+1)); echo "${d#$W/} $delta"; fi
done
echo "ROWS_READ=$n ROWS_WITH_DELTA=$hit"
