#!/usr/bin/env bash
# r10earl77 -- STAGE 1 of the mover prediction, and the corpus FENCE SCAN:
# find every corpus test whose SOURCE spells a PORT whose written type is a
# SCOPED package type name.  A database-side predictor keys on the typespec we
# already emit and is therefore blind to a port whose typespec we render
# anonymously; this one reads the source and is not.
# The four slang-fenced tests are NEVER dispatched -- this script only READS
# files, and their names are not spelled here (FENCED= lists nothing).
#   usage: fencescan77.sh <root> [<root> ...]
set -u
FENCED=""
for R in "$@"; do
  for d in "$R"/*/; do
    n=$(basename "$d")
    case " $FENCED " in *" $n "*) echo "FENCED-SKIP $n"; continue;; esac
    c=$(grep -rlE '^[[:space:]]*(input|output|inout)([[:space:]]+(wire|var|tri|logic|reg))?[[:space:]]+[A-Za-z_][A-Za-z_0-9]*::[A-Za-z_]' \
          --include='*.sv' --include='*.svh' --include='*.v' "$d" 2>/dev/null | wc -l)
    [ "$c" -gt 0 ] && echo "SRC-CANDIDATE $c $n"
  done
done
