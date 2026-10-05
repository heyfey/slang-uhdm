#!/bin/bash
# v11u255 dscases.sh <workroot>: the downstream verdict (r11u255repro/drivers/dscases.py, the harness's one()) of
# every C and E case on both binaries. Fail-closed on $FENCED (dscases.py refuses a fenced path too).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
cases=$(find "$D/../cases/C" "$D/../cases/E" -mindepth 1 -maxdepth 1 -type d | sort | grep -vwE "$FENCE_RE")
cd "$REPO"
for t in P L; do b=$B/pristine; [ $t = L ] && b=$B/law; SLANG_UHDM=$b python3 "$R255D/dscases.py" $t "$1" $cases; done
