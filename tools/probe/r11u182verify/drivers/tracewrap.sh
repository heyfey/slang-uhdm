#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for a firing census (r11u182; after r11u174repro/drivers/tracewrap.sh): runs
# $LAWBIN with $TRACEVAR=1, appends "<output path> <count> <trace line>" per distinct firing (lines starting with
# $TRACEPAT) to $CENLOG, passes every other stderr line and the exit code through unchanged.
LAWBIN=${LAWBIN:?LAWBIN}; CENLOG=${CENLOG:?CENLOG}; TRACEVAR=${TRACEVAR:?TRACEVAR}; TRACEPAT=${TRACEPAT:?TRACEPAT}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
e=$(mktemp /tmp/r11u182_cen_e.XXXXXX)
env $TRACEVAR=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E "^($TRACEPAT)" "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev "^($TRACEPAT)" "$e" >&2
rm -f "$e"
exit $rc
