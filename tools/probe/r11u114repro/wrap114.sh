#!/bin/bash
# wrap114.sh — the CENSUS wrapper (r11u114).  Point verify_golden.py's SLANG_UHDM at this
# script; it runs CEN (the law tree + census114.diff, i.e. the law binary with stderr
# fire logs and byte-identical output) and appends each R11U114FIRE line, keyed by the
# -o path, to ${FIRELOG}.
CEN=${CEN:?set CEN to the census binary}; FIRELOG=${FIRELOG:?set FIRELOG}
out=""; prev=""; for a in "$@"; do [ "$prev" = "-o" ] && out=$a; prev=$a; done
tmp=$(mktemp "${FIRELOG}.err.XXXXXX")
"$CEN" "$@" 2> "$tmp"; rc=$?
grep 'R11U114FIRE' "$tmp" | sed "s#^#$out #" >> "$FIRELOG"
grep -v 'R11U114FIRE' "$tmp" >&2
rm -f "$tmp"
exit $rc
