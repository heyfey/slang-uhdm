#!/bin/bash
# sweep.sh <workdir> <binary> [ENV=VAL ...]: the gate sweep (tests/sweep.sh --jobs 3: probe, surelog, uhdm2rtlil,
# downstream) of THIS checkout with SLANG_UHDM=<binary>, run from the checkout (never the main tree's cwd), log in
# <workdir>.log. The gate dispatches every row as it mandates; nothing here names or reads a fenced row.
source "$(dirname "$0")/env.sh" || exit 2
W=$1; B=$2; shift 2
[ -x "$B" ] || { echo "sweep.sh: $B not executable" >&2; exit 2; }
mkdir -p "$W"
cd "$REPO" && env "$@" SLANG_UHDM="$B" bash tests/sweep.sh --jobs 3 --workdir "$W" > "$W.log" 2>&1
echo "EXIT=$?" >> "$W.log"
