#!/usr/bin/env bash
# r10buvm24repro/sweeps24.sh — run BOTH corpora with ONE frozen binary into a
# workdir this pass owns.  MEASUREMENT PLUMBING ONLY: scripts/verify_golden.py
# and uhdm-cmp are the authorities.
#
# The two traps this exists to avoid: verify_golden.py silently defaults
# SLANG_UHDM to the MAIN-TREE binary (so it is exported here, per binary), and
# rc=139 segfaults are recorded as SLANG_REJECT (so the status histogram is
# printed and must be read).
#
#   sweeps24.sh <binary> <workroot> <repo worktree>
set -u
BIN=$1; W=$2; REPO=$3
mkdir -p "$W/sl" "$W/u2r"
export SLANG_UHDM=$BIN
( cd "$REPO" && python3 scripts/verify_golden.py --corpus surelog --mode both \
    --jobs 2 --out "$W/sl.csv" --workdir "$W/sl" > "$W/sl.log" 2>&1; echo DONE >> "$W/sl.log" ) &
( cd "$REPO" && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
    --jobs 2 --out "$W/u2r_tf.csv" --workdir "$W/u2r" > "$W/u2r_tf.log" 2>&1
  cd "$REPO" && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default \
    --jobs 2 --out "$W/u2r_def.csv" --workdir "$W/u2r" > "$W/u2r_def.log" 2>&1
  echo DONE >> "$W/u2r_def.log" ) &
wait
echo "== cmds.txt binary audit (must be $BIN everywhere)"
find "$W" -name cmds.txt -exec grep -h '^slang:' {} \; | awk '{print $2}' | sort | uniq -c
for f in "$W/sl.csv" "$W/u2r_tf.csv" "$W/u2r_def.csv"; do
  echo "== $f"; cut -d, -f3 "$f" | sort | uniq -c
done
