#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for the fix census sweep: runs the fix binary with R11V159_TRACE=1,
# appends "<output path> <firing>" per firing to $CENLOG, passes every other stderr line and the exit code
# through unchanged (the database is the fix binary's own).
LAWBIN=${LAWBIN:-/tmp/r11u159_bin/fix.bin}
CENLOG=${CENLOG:-/tmp/r11u159_cen/census.log}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
mkdir -p $(dirname $CENLOG); e=$(mktemp /tmp/r11u159_cen/e.XXXXXX)
R11V159_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^R11V159 ' "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^R11V159 ' "$e" >&2
rm -f "$e"
exit $rc
