#!/usr/bin/env bash
# r10oth7 — EXPLAIN EVERY BYTE MOVER.  Runs ctmints.sh over each mover the byte
# verifier named, so the write-up can attribute every one of them to a law
# instead of asserting that it can.
#
#   usage: ctexplain.sh <pristine-workdir-root> <patched-workdir-root> <name>...
#
# A name is the workdir directory basename (e.g. SVSwitch-db796243).  Both modes
# are tried; a mode with no database on either side prints UNMEASURED rather than
# being silently skipped.
set -u
PRI=${1:?pristine workdir root}
FIN=${2:?patched workdir root}
shift 2
HERE=$(cd "$(dirname "$0")" && pwd)
for t in "$@"; do
  for m in default testflags; do
    a="$PRI/$m/$t/slang.uhdm"
    b="$FIN/$m/$t/slang.uhdm"
    if [ ! -f "$a" ] || [ ! -f "$b" ]; then
      echo "$t $m: UNMEASURED (no database on one side)"
      continue
    fi
    if cmp -s "$a" "$b"; then
      echo "$t $m: NOT A MOVER (byte-identical)"
      continue
    fi
    bash "$HERE/ctmints.sh" "$a" "$b" "${m}_${t}"
  done
done
