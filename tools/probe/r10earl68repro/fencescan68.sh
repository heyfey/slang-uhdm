#!/usr/bin/env bash
# r10earl68 — run gvfence68 over every .uhdm a PRISTINE sweep produced, and
# print the databases that carry a cell § genvarWholeCaRhsFold68 could move.
# MEASUREMENT ONLY.   usage: fencescan68.sh <sweep-workdir> <out.txt>
set -u
T=${GVFENCE68:?set GVFENCE68}
W=${1:?workdir}; O=${2:?out}
: > "$O"
find "$W" -name '*.uhdm' -not -name 'golden*' 2>/dev/null | sort | while read -r f; do
  n=$("$T" "$f" 2>/dev/null | wc -l)
  [ "$n" -gt 0 ] && echo "$f $n" >> "$O"
done
echo "DBS_WITH_CELLS $(wc -l < "$O")"
