#!/bin/bash
# tracewrap.sh — SLANG_UHDM stand-in for the census sweep: runs $LAWBIN with R11U154_TRACE=1,
# appends "<output path> <count> R11U154_TRACE <law>" per firing to $CENLOG, passes every other
# stderr line and the exit code through unchanged.
LAWBIN=${LAWBIN:-/tmp/r11u154_bin/law}
CENLOG=${CENLOG:-/tmp/r11u154_cen/census.log}
o=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && o=$a; prev=$a; done
mkdir -p $(dirname $CENLOG); e=$(mktemp /tmp/r11u154_cen_e.XXXXXX)
R11U154_TRACE=1 "$LAWBIN" "$@" 2>"$e"; rc=$?
grep -E '^R11U154_TRACE ' "$e" | sort | uniq -c | sed "s#^#$o #" >> "$CENLOG"
grep -Ev '^R11U154_TRACE ' "$e" >&2
rm -f "$e"
exit $rc
