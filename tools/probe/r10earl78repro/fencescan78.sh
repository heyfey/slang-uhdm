#!/usr/bin/env bash
# r10earl78 — run replfence78 over every .uhdm produced by a sweep workdir and
# report the databases carrying a cell § genCaReplWholeFold78 could move
# (a GEN-scope cont_assign whose whole Rhs is a vpiMultiConcatOp), plus the MOD
# controls and the CASTCAND siblings.  MEASUREMENT ONLY.
#   usage: FENCE78=<bin> fencescan78.sh <sweep-workdir> <out-prefix>
set -u
F=${FENCE78:?set FENCE78 to the replfence78 binary}
W=${1:?sweep workdir}; O=${2:?out prefix}
: > "$O.raw"; n=0
while IFS= read -r db; do
  n=$((n+1))
  d=$(dirname "$db")
  "$F" "$db" 2>/dev/null | sed "s#^#$d | #"
done < <(find "$W" -name 'slang.uhdm' -print | sort) >> "$O.raw"
echo "DATABASES_SCANNED=$n" > "$O.tally"
echo "GEN_REPL_DATABASES=$(grep '| REPL GEN' "$O.raw" | cut -d'|' -f1 | sort -u | wc -l)" >> "$O.tally"
echo "GEN_REPL_CELLS=$(grep -c '| REPL GEN' "$O.raw" || true)" >> "$O.tally"
echo "MOD_REPL_CELLS=$(grep -c '| REPL MOD' "$O.raw" || true)" >> "$O.tally"
echo "GEN_CAST_CELLS=$(grep -c '| CASTCAND GEN' "$O.raw" || true)" >> "$O.tally"
cat "$O.tally"
