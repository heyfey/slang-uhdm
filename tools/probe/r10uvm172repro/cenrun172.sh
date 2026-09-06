#!/usr/bin/env bash
# r10uvm172repro/cenrun172.sh — run ct172cen over EVERY row of a verify_golden
# workdir (golden side and our side) and score each row with score172.py.
# MEASUREMENT ONLY.
#   cenrun172.sh <workdir> <outdir> [<name filter regex>]
#
# GUARDS: the golden path is read out of the row's OWN cmds.txt (so the wrong
# golden can never be scored), BOTH sides are existence-checked and a missing
# side is printed as SKIP and COUNTED — a runner that reaches nothing must not
# read as perfection (r10uvm67's rowheads law).
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; FILT=${3:-.}
CEN=${CT172CEN:-/tmp/r10uvm172_ct172cen}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -x "$CEN" ] || { echo "FATAL: no ct172cen at $CEN"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT"
n=0; skip=0
for mode in default testflags; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    row=$(basename "$d"); row=${row%-*}
    echo "$mode/$row" | grep -qE "$FILT" || continue
    O=$d/slang.uhdm; C=$d/cmds.txt; G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP $mode $row"; skip=$((skip+1)); continue
    fi
    "$CEN" "$G" > "$OUT/$row.$mode.g.txt" 2>/dev/null
    "$CEN" "$O" > "$OUT/$row.$mode.o.txt" 2>/dev/null
    printf "%-28s %-9s %s\n" "$row" "$mode" \
      "$(python3 "$HERE/score172.py" "$OUT/$row.$mode.g.txt" "$OUT/$row.$mode.o.txt")"
    n=$((n+1))
  done
done
echo "-- scored=$n SKIP=$skip"
