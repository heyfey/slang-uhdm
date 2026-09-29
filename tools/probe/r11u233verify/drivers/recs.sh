#!/bin/bash
# r11u233: recs.sh <db.uhdm> <out>: the gate comparator's own record list of one database (uhdm-strictcmp self-walk,
# --dump-a), one record per line: depth, type, name, defname, fullname, file, line, col, endline, endcol, decompile, size,
# value, consttype.  Reads only the database it is given (never a fenced one: the caller's paths are case stores).
source "$(dirname "$0")/env.sh" || exit 2
[ -x "$STRICT_CMP" ] || { echo "recs.sh: STRICT_CMP not executable" >&2; exit 2; }
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo "recs.sh: fenced path refused" >&2; exit 2; }; done
"$STRICT_CMP" --max 0 --dump-a "$2" --dump-b /dev/null "$1" "$1" > /dev/null 2>&1
