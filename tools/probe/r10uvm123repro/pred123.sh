#!/usr/bin/env bash
# r10uvm123 — A-PRIORI mover prediction from the PRISTINE databases alone.
# A database moves iff it holds a vpiCastOp whose target is a RANGED bit/logic
# typespec carrying a package-QUALIFIED name (i.e. the package's LISTING
# object, not a per-use clone).  Prints one line per database, then the names.
# MEASUREMENT ONLY.   usage: CAST123=.. pred123.sh <workdir> [<workdir> ...]
set -u
CEN=${CAST123:?set CAST123}
tot=0; hit=0
for WD in "$@"; do
  while IFS= read -r db; do
    tot=$((tot+1))
    n=$("$CEN" "$db" 2>/dev/null | awk '
      /tgt=(bit|logic)_typespec/ && /name=[^ ]*::/ && /alias=- / && !/L=- / {c++}
      END{print c+0}')
    if [ "$n" -gt 0 ]; then hit=$((hit+1)); echo "PREDICT $n $db"; fi
  done < <(find "$WD" -name slang.uhdm | sort)
done
echo "-- scanned=$tot predicted-movers=$hit"
