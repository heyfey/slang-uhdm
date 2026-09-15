#!/bin/bash
# v11u34 RE-DRAW: run ONE binary N times on the sweep's own command line for a
# named row and print the resulting database md5 each time.  The command line
# is read from the sweep's cmds.txt with the output path retargeted to a
# throwaway file, so the draw is the only thing that varies.
#   usage: redraw.sh <sweep_root> <mode/rowdir> <binary> <N>
set -u
ROOT=${1:?sweep root}; P=${2:?mode/rowdir}; BIN=${3:?binary}; N=${4:-3}
D=$ROOT/$P
CMD=$(grep '^slang:' "$D/cmds.txt" | head -1 | sed 's/^slang:[[:space:]]*//')
# replace the leading binary and the -o target
REST=${CMD#* }
OUT=/tmp/v11u34_redraw_$$.uhdm
REST=$(printf '%s' "$REST" | sed -E "s#-o [^ ]+#-o $OUT#")
for i in $(seq 1 "$N"); do
    rm -f "$OUT"
    ( cd "$D" && eval "$BIN $REST" > /dev/null 2>&1 )
    printf '%s draw%d: %s size=%s\n' "$P" "$i" \
        "$(md5sum "$OUT" 2>/dev/null | cut -c1-12)" \
        "$(stat -c %s "$OUT" 2>/dev/null)"
done
rm -f "$OUT"
