#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for the firing census: runs $LAWBIN with R11U157_TRACE=1 and
# R11U158_TRACE=1, appends "<output path> <count> <trace line>" per distinct firing to $CENLOG,
# passes every other stderr line and the exit code through unchanged.
LAWBIN=${LAWBIN:?LAWBIN}; CENLOG=${CENLOG:?CENLOG}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
e=$(mktemp /tmp/r11u158_cen_e.XXXXXX)
R11U157_TRACE=1 R11U158_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^(R11U158_TRACE |R11U157 route |R11U157 law )' "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^(R11U158_TRACE |R11U157 )' "$e" >&2
rm -f "$e"
exit $rc
