#!/usr/bin/env bash
# r10uvm217 — FENCE SCRUB.  The corpus censuses in this directory walk a
# verify_golden SWEEP WORKDIR, and that workdir contains rows for the four
# SLANG-FENCED tests: the harness builds them, this pass never dispatches them,
# but their NAMES would otherwise be printed in a census artifact.  The standing
# rules say the fenced names are listed in `FENCED=` and nowhere else, so this
# script reads the list OUT OF `canaudit.sh` (it never spells one itself) and
# redacts every occurrence from the artifacts.
#
#   usage: ./scrub217.sh <file> [<file> ...]
#
# The check that it worked is `canaudit.sh`'s own FENCE-BREACH counter, which
# searches every file in this directory except itself and the write-ups.
# Run this BEFORE the final canaudit, and re-run canaudit after.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
[ -f "$HERE/canaudit.sh" ] || { echo "FATAL: no canaudit.sh next to me"; exit 3; }
LIST=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/canaudit.sh")
[ -n "$LIST" ] || { echo "FATAL: could not read FENCED= out of canaudit.sh"; exit 4; }
n=0
for f in "$@"; do
  [ -f "$f" ] || { echo "  skip (absent) $f"; continue; }
  before=$(wc -c < "$f")
  for name in $LIST; do
    # Redact the NAME, not the row: a row that vanished silently would make a
    # census read cleaner than it measured.
    sed -i "s/\b$name\b/<FENCED-TEST>/g" "$f"
  done
  after=$(wc -c < "$f")
  echo "  scrubbed $f ($before -> $after bytes)"
  n=$((n+1))
done
echo "-- SCRUBBED $n file(s) against $(echo "$LIST" | wc -w) fenced names"
