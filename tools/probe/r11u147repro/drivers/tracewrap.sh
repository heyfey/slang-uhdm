#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for the census sweep: runs $LAWBIN with
# R11U147_TRACE=1 and R11U151_TRACE=1 (the landed r11u151 law), appends "<output path> <law>" per
# firing to $CENLOG, and
# passes every other stderr line and the exit code through unchanged.
LAWBIN=${LAWBIN:-/tmp/r11u147_bin/law}
CENLOG=${CENLOG:-/tmp/r11u147_cen/census.log}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
e=$(mktemp /tmp/r11u147_cen/e.XXXXXX)
R11U147_TRACE=1 R11U151_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^(R11U147_TRACE|R11U151) ' "$e" | sed 's/^R11U151 /R11U151 R11U151:/' | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^(R11U147_TRACE|R11U151) ' "$e" >&2
rm -f "$e"
exit $rc
