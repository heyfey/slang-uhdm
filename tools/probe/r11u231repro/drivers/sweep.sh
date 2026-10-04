#!/bin/bash
# sweep.sh <binary> <workdir> [sweep.sh args...]: the gate sweep (tests/sweep.sh --jobs 3) with the pins exported
# and SLANG_UHDM set to the given frozen binary; the log lands at <workdir>.log.
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$H/env.sh" || exit 2
b=$1; w=$2; shift 2
[ -x "$b" ] || { echo "sweep: $b not executable" >&2; exit 2; }
export SLANG_UHDM=$b STRICT_CMP=$B/uhdm-strictcmp
unset GOLDEN_DEFER
cd "$REPO" && tests/sweep.sh --jobs 3 --workdir "$w" "$@" > "$w.log" 2>&1; echo "exit=$?" >> "$w.log"
