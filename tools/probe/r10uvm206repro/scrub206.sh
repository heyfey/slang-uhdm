#!/usr/bin/env bash
# r10uvm206repro/scrub206.sh — REDACT THE SLANG-FENCED TEST NAMES from this
# directory's evidence files, and TRIM the per-row listings to what a reader
# needs (the summary lines plus every row that is not all-zero).
#
# The corpus censuses and the mover predictor walk a whole sweep workdir, so
# their raw output NAMES every row — the four slang-fenced tests included.  The
# standing rule is that those names must not be spelled in a probe artifact, so
# this reads the fence list OUT OF canaudit.sh (it never spells them itself) and
# replaces each with `<FENCED>`.  canaudit.sh's own FENCE-BREACH counter is the
# check that this worked.
#
#   usage: ./scrub206.sh <file>...
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
FENCED=$(awk -F'"' '/^FENCED=/{print $2}' "$HERE/canaudit.sh")
[ -n "$FENCED" ] || { echo "could not read the fence list from canaudit.sh"; exit 2; }
SED=""
for f in $FENCED; do SED="$SED s/\\b$f\\b/<FENCED>/g;"; done
for file in "$@"; do
  [ -f "$file" ] || { echo "MISSING $file"; continue; }
  sed -i "$SED" "$file"
  echo "scrubbed $file"
done
