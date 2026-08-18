#!/usr/bin/env bash
# r10uvm93 sweep driver — runs the OFFICIAL harness with an EXPLICITLY exported
# SLANG_UHDM (verify_golden.py silently defaults to the MAIN-TREE binary) into
# THIS pass's own --out/--workdir, then prints the binary path each cmds.txt
# actually recorded so the arm can never be attributed to the wrong build.
set -u
WT=${WT:?worktree root}
BIN=${BIN:?frozen binary}
W=${W:?workdir root}
mkdir -p "$W/sl" "$W/u2r"
export SLANG_UHDM="$BIN"
cd "$WT" || exit 9
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
        --out "$W/u2r_tf.csv" --workdir "$W/u2r" > "$W/u2r_tf.log" 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default  --jobs 2 \
        --out "$W/u2r_def.csv" --workdir "$W/u2r" > "$W/u2r_def.log" 2>&1
python3 scripts/verify_golden.py --corpus surelog    --mode both     --jobs 2 \
        --out "$W/sl.csv" --workdir "$W/sl" > "$W/sl.log" 2>&1
echo "---- binary paths recorded in cmds.txt (must all be $BIN)"
find "$W" -name cmds.txt -print0 | xargs -0 grep -ho 'slang: *[^ ]*' | sort | uniq -c
