#!/bin/bash
# r11u233: census.sh <workdir> <trace dir> [ENV=VAL ...]: the gate sweep of HEAD (tests/sweep.sh --jobs 3: probe, surelog,
# uhdm2rtlil, downstream; the gate dispatches every row as it mandates, nothing here reads a fenced row) with
# SLANG_UHDM=$LAW and R11U227_TRACE / R11U228_TRACE = <trace dir>: one trace file per slang-uhdm process that fired a
# law of pass 227 (`<pid>.227`) or pass 228 (`<pid>.228`), first line `OUT <-o path>`.  The same sweep is the ON state
# of the composition census; its bytes are checked against the untraced integration sweep (byte-neutral trace).
source "$(dirname "$0")/env.sh" || exit 2
W=$1; T=$2; shift 2; rm -rf "$T"; mkdir -p "$T"
bash "$(dirname "$0")/sweep.sh" "$W" "$LAW" R11U227_TRACE="$T" R11U228_TRACE="$T" "$@"
