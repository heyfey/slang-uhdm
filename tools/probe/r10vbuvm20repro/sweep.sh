#!/usr/bin/env bash
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
echo "DONE $W"
