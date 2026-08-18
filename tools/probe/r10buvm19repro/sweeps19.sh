#!/usr/bin/env bash
# r10buvm19repro/sweeps19.sh — run BOTH corpora, BOTH modes, with ONE named
# binary, into a workdir this pass owns.  The binary is passed by PATH and
# asserted out of every cmds.txt afterwards (verify_golden.py silently
# defaults SLANG_UHDM to the MAIN-TREE binary — RESUME §9).
#
# usage: sweeps19.sh <slang-binary> <workroot> <repo-root>
set -u
BIN=$1; W=$2; R=$3
mkdir -p "$W/sl" "$W/u2r"
export SLANG_UHDM="$BIN"
( cd "$R" && python3 scripts/verify_golden.py --corpus surelog --mode both \
      --jobs 2 --out "$W/sl.csv" --workdir "$W/sl" > "$W/sl.log" 2>&1 ) &
( cd "$R" && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
      --jobs 2 --out "$W/u2r_tf.csv" --workdir "$W/u2r" > "$W/u2r_tf.log" 2>&1
  cd "$R" && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default \
      --jobs 2 --out "$W/u2r_def.csv" --workdir "$W/u2r" > "$W/u2r_def.log" 2>&1 ) &
wait
echo "== cmds.txt binary audit (must name ONLY $BIN)"
grep -rho 'slang: *[^ ]*' "$W"/sl "$W"/u2r --include=cmds.txt | sort -u
