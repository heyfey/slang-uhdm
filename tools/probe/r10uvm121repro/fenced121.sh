#!/usr/bin/env bash
# r10uvm121repro/fenced121.sh — answers rc 0 when the path names a SLANG-FENCED
# test, rc 1 otherwise.  MEASUREMENT ONLY.
#
# The four names are READ OUT of canaudit.sh's own `FENCED=` line — the
# campaign's single authority for that list — so that no probe artifact of this
# pass ever spells them, which is exactly what canaudit.sh reads as a
# FENCE-BREACH.  Only a COUNT of skipped paths is ever printed by the caller.
set -u
p=${1:-}
HERE=$(cd "$(dirname "$0")" && pwd)
LIST=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/canaudit.sh" | head -1)
[ -z "$LIST" ] && { echo "fenced121: cannot read the fence list" >&2; exit 2; }
for n in $LIST; do
  case "$p" in *"$n"*) exit 0;; esac
done
exit 1
