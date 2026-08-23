#!/usr/bin/env bash
# r10earl77 -- MOVER PREDICTOR, run on the PRISTINE databases BEFORE the patched
# sweep.  Stage 2 of the prediction (stage 1 is the source scan, fencescan77.sh):
# a database can move under § pkgScopedPortAnyDirVar77 only if it already holds
# a PORT whose backing object is a NET and whose port typespec carries a SCOPED
# (`pkg::T`) name.  Prints one line per candidate database with the cells.
#   usage: predict77.sh <workdir> [<workdir> ...]
set -u
CEN=${CEN77:?}
for WD in "$@"; do
  for db in "$WD"/*/*/slang.uhdm; do
    [ -f "$db" ] || continue
    n=$("$CEN" "$db" 2>/dev/null \
        | grep -E '\|TS=[a-z_]+/[A-Za-z_0-9]+::' | grep -E '\|BACK=(NET|ANET):' | wc -l)
    [ "$n" -gt 0 ] || continue
    echo "CANDIDATE $n $db"
  done
done
