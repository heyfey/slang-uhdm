#!/bin/bash
# § ifaceDefNetTypespecIsTheModuleRule224 — THE PREDICTOR SHIM.
#
# Stands in for $SLANG_UHDM during a verify_golden sweep.  It execs the
# PREDICTOR binary (the patched tree with the new gate wrapped so that
# SLANG224_PRED=1 REPORTS and DECLINES — observable behaviour pristine) and
# keeps that row's stderr in its own file, keyed on the -o database path the
# harness chose, so the report can be attributed to a row-mode by NAME.
#
#   PRED224_BIN=<predictor>  PRED224_LOG=<dir>  SLANG224_PRED=1
#
# The shim must NEVER swallow the child's exit status: verify_golden reads
# rc=139 segfaults as SLANG_REJECT, and a shim that returned 0 would hide one.
set -u
BIN=${PRED224_BIN:?export PRED224_BIN}
LOG=${PRED224_LOG:?export PRED224_LOG}
mkdir -p "$LOG"
out=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && out="$a"; prev="$a"; done
key=$(printf '%s' "$out" | tr '/' '_')
"$BIN" "$@" 2> "$LOG/$key.err"
rc=$?
cat "$LOG/$key.err" >&2
exit $rc
