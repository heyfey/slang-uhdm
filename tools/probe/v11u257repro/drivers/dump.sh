#!/bin/bash
# v11u257 dump.sh <db.uhdm>: uhdm-dump with the tool checked ([ -x ]) and ids dropped; a fenced path is refused.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
echo "$1" | grep -qwE "$FENCE_RE" && { echo "dump.sh: fenced path refused" >&2; exit 2; }
[ -x "$UHDM_DUMP" ] || exit 2
"$UHDM_DUMP" "$1" 2>&1 | sed 's/, id:[0-9]*//; s/id:[0-9]*//'
