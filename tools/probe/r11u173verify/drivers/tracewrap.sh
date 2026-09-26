#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for the firing census (after r11u167repro/drivers/tracewrap.sh): runs $LAWBIN with
# R11V173_TRACE=1, appends "<output path> <count> <trace line>" per distinct firing to $CENLOG, passes every other
# stderr line and the exit code through unchanged.  Dispatched only by census.sh, whose --filter excludes the fenced
# tests (this wrapper reads no source or database itself).
LAWBIN=${LAWBIN:?LAWBIN}; CENLOG=${CENLOG:?CENLOG}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
e=$(mktemp /tmp/r11u173_cen_e.XXXXXX)
R11V173_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^R11V173_TRACE ' "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^R11V173_TRACE ' "$e" >&2
rm -f "$e"
exit $rc
