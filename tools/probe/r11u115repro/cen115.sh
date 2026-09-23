#!/bin/bash
# cen115.sh <sweep-workdir> [calib]: per row (mode/name-hash dir holding slang.uhdm), the cen115
# signature of GOLDEN and OURS: F1 count deltas (golden minus ours) and the PV multiset
# difference (param_assign values of interface_insts present only on one side).  Prints only
# rows with a nonzero delta, plus a summary.  "calib" reads the golden database as BOTH sides.
W=${1:?workdir}; MODE=${2:-}
CEN=${CEN:-/tmp/r11u115_bin/cen115}
HERE=$(cd "$(dirname "$0")" && pwd)
export LD_LIBRARY_PATH=$HOME/.local/lib64
T=$(mktemp -d /tmp/r11u115_cen.XXXX)
n=0; hit=0
for d in $(find "$W" -name cmds.txt -printf '%h\n' | sort); do
  [ -f "$d/slang.uhdm" ] || continue
  c=$(grep -o 'cache hit [^)]*' "$d/cmds.txt" | awk '{print $3}')
  if [ -n "$c" ]; then g="$c/golden.uhdm"; else g=$(ls "$d"/slpp_*/surelog.uhdm 2>/dev/null | head -1); fi
  [ -f "$g" ] || continue
  n=$((n+1))
  timeout 600 $CEN "$g" > $T/g; if [ "$MODE" = calib ]; then timeout 600 $CEN "$g" > $T/o; else timeout 600 $CEN "$d/slang.uhdm" > $T/o; fi
  r=$(python3 "$HERE/censcore115.py" $T/g $T/o)
  if [ -n "$r" ]; then hit=$((hit+1)); echo "${d#$W/} $r"; fi
done
rm -rf $T
echo "ROWS_READ=$n ROWS_WITH_DELTA=$hit"
