#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for the firing census of the r11u170 refinements: runs $LAWBIN with
# R11V170_TRACE=1, appends "<output path> <count> <trace line>" per distinct firing to $CENLOG, passes every
# other stderr line and the exit code through unchanged.  (Adapted from tools/probe/r11u163repro/drivers.)
LAWBIN=${LAWBIN:?LAWBIN}; CENLOG=${CENLOG:?CENLOG}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
e=$(mktemp /tmp/r11u170_tmp/cen_e.XXXXXX)
R11V170_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^(R11V170_TRACE )' "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^(R11V170_TRACE )' "$e" >&2
rm -f "$e"
exit $rc
