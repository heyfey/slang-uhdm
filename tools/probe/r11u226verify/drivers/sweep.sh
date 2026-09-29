#!/bin/bash
# sweep.sh <workdir> <binary> [ENV=VAL ...]: the full gate sweep (tests/sweep.sh --jobs 3: probe, surelog, uhdm2rtlil,
# downstream) of this checkout with SLANG_UHDM=<binary> and the given switch environment; log <workdir>.log, the
# environment recorded in <workdir>.env.  The gate dispatches every row as it mandates (the fenced rows included,
# by the harness only); nothing here reads a fenced row.
source "$(dirname "$0")/env.sh" || exit 2
W=$1; BIN=$2; shift 2
[ -x "$BIN" ] || { echo "sweep.sh: $BIN not executable" >&2; exit 2; }
rm -rf "$W"; mkdir -p "$W"
echo "BIN=$BIN md5=$(md5sum < $BIN | cut -c1-12) ENV=$* start=$(date '+%F %T')" > "$W.env"
( cd "$R226_ROOT" && env "$@" SLANG_UHDM="$BIN" bash tests/sweep.sh --jobs ${JOBS:-3} --workdir "$W" ${CORPUS:+--corpus "$CORPUS"} > "$W.log" 2>&1; echo "EXIT=$?" >> "$W.log" )
echo "end=$(date '+%F %T')" >> "$W.env"
