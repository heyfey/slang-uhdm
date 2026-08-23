#!/bin/bash
# r10buvm30 — corpus census of NEGATIVE-DECOMPILE constants and vpiMinusOp
# operations, golden AND ours, over every database of a verify_golden.py
# workdir.  MEASUREMENT ONLY; the official uhdm-cmp remains the judge.
#
#   runcen30.sh <workdir-root> <corpus-tag> <out-prefix>
#
# <workdir-root> is the `sl` or `u2r` directory of YOUR OWN sweep workdir
# (never a shared control).  Writes <out-prefix>.dbs.txt, .golden.tsv, .ours.tsv.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AWKF="$HERE/negcen30.awk"
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
W="$1"; TAG="$2"; OUT="$3"
: > "$OUT.dbs.txt"
for MODEDIR in "$W"/*; do
  [ -d "$MODEDIR" ] || continue
  MODE=$(basename "$MODEDIR")
  for D in "$MODEDIR"/*; do
    [ -f "$D/cmds.txt" ] || continue
    T=$(basename "$D"); T=${T%-*}
    G=$(grep -o 'golden cache hit [^)]*' "$D/cmds.txt" | sed 's/golden cache hit //')
    if [ -n "$G" ] && [ -f "$G/golden.uhdm" ]; then
      printf '%s\t%s\t%s\t%s\t%s\n' "$TAG" "$T" "$MODE" "$G/golden.uhdm" "$D/slang.uhdm" >> "$OUT.dbs.txt"
    fi
  done
done
export OUT AWKF DUMP
cen() {
  IFS=$'\t' read -r tag t mode g o <<< "$1"
  [ -f "$g" ] && "$DUMP" "$g" 2>/dev/null | \
      awk -v TEST="$t" -v MODE="$mode" -f "$AWKF" >> "$OUT.golden.$$.tsv"
  [ -f "$o" ] && "$DUMP" "$o" 2>/dev/null | \
      awk -v TEST="$t" -v MODE="$mode" -f "$AWKF" >> "$OUT.ours.$$.tsv"
  return 0
}
export -f cen
xargs -d '\n' -P 2 -I{} bash -c 'cen "$@"' _ {} < "$OUT.dbs.txt"
cat "$OUT".golden.[0-9]*.tsv > "$OUT.golden.tsv" 2>/dev/null
cat "$OUT".ours.[0-9]*.tsv   > "$OUT.ours.tsv"   2>/dev/null
rm -f "$OUT".golden.[0-9]*.tsv "$OUT".ours.[0-9]*.tsv
wc -l "$OUT.dbs.txt" "$OUT.golden.tsv" "$OUT.ours.tsv"
