#!/usr/bin/env bash
# r10vbuvm31repro/vsweep31.sh — ONE binary per invocation, SLANG_UHDM exported
# EXPLICITLY to it (verify_golden.py silently defaults to the MAIN-TREE binary
# — RESUME §9), GOLDEN_DEFER left unset, --jobs 2.  Audit the result with
#   find <workdir> -name cmds.txt -exec grep -L '<binary path>' {} \;
#   vsweep31.sh <worktree> <binary> <workdir root>
set -u
W=${1:?worktree}; BIN=${2:?binary}; R=${3:?workdir root}
mkdir -p "$R/sl" "$R/u2r"
export SLANG_UHDM=$BIN
unset GOLDEN_DEFER
cd "$W" || exit 1
echo "=== binary=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
        --out "$R/u2r_tf.csv"  --workdir "$R/u2r" > "$R/u2r_tf.log" 2>&1
echo "u2r_tf rc=$?"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default  --jobs 2 \
        --out "$R/u2r_def.csv" --workdir "$R/u2r" > "$R/u2r_def.log" 2>&1
echo "u2r_def rc=$?"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 \
        --out "$R/sl.csv" --workdir "$R/sl" > "$R/sl.log" 2>&1
echo "sl rc=$?"
