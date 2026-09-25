#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for the firing census: runs $LAWBIN with R11U167_TRACE=1,
# appends "<output path> <count> <trace line>" per distinct firing to $CENLOG,
# passes every other stderr line and the exit code through unchanged.
LAWBIN=${LAWBIN:?LAWBIN}; CENLOG=${CENLOG:?CENLOG}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
e=$(mktemp /tmp/v11u167_cen_e.XXXXXX)
R11U167_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^(R11U167_TRACE )' "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^(R11U167_TRACE )' "$e" >&2
rm -f "$e"
exit $rc
