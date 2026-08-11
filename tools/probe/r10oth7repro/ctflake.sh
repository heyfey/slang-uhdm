#!/usr/bin/env bash
# r10oth7 — settle a byte question on a KNOWN-NONDETERMINISTIC database.
# Scoreboard's default database is intermittently nondeterministic on EVERY
# binary (r10oth5 C7, r10oth6 §4.2), so a flat mover count that ignores it reads
# as a regression to the next verifier.  This runs ONE test N times per binary
# and prints the md5 of each database, so "both binaries emit both md5s" can be
# stated as a measurement instead of an excuse.
#
#   usage: ctflake.sh <test-name> <binaryA> <binaryB> [reps] [mode]
#
# Uses its own workdir per rep so no run can read another's leftovers.
set -u
T=${1:?test name}
A=${2:?binary A}
B=${3:?binary B}
N=${4:-4}
MODE=${5:-default}
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../.." && pwd)
for bin in "$A" "$B"; do
  [ -x "$bin" ] || { echo "FATAL: not executable: $bin"; exit 9; }
  echo "== $(md5sum "$bin" | cut -c1-12)  $bin"
  for i in $(seq 1 "$N"); do
    wd=/tmp/r10oth7_flake_$$_$(basename "$bin")_$i
    rm -rf "$wd"
    SLANG_UHDM="$bin" python3 "$ROOT/scripts/verify_golden.py" --corpus surelog \
      --mode "$MODE" --filter "$T" --jobs 1 \
      --out "$wd.csv" --workdir "$wd" >/dev/null 2>&1
    f=$(find "$wd" -name slang.uhdm | head -1)
    if [ -z "$f" ]; then
      echo "  rep $i: UNMEASURED (no database produced)"
    else
      echo "  rep $i: $(md5sum "$f" | cut -c1-12)"
    fi
    rm -rf "$wd" "$wd.csv"
  done
done
