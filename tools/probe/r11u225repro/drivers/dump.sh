#!/bin/bash
# dump.sh <db.uhdm> : uhdm-dump with the pins sourced and the tool guarded (never execute a database).
. "$(dirname "$0")/env.sh" || exit 2
[ -x "$UHDM_DUMP" ] || { echo "dump.sh: UHDM_DUMP not executable" >&2; exit 2; }
[ -f "$1" ] || { echo "dump.sh: no file $1" >&2; exit 2; }
"$UHDM_DUMP" "$1" 2>&1 | sed "s#file:[^ ,]*/#file:#g"
