#!/usr/bin/env bash
# r10uvm116repro/cenall116.sh -- run cen116.py over the golden AND our database
# of every named (test,mode) cell of a verify_golden workdir.  MEASUREMENT ONLY.
#
#   cenall116.sh <workdir> <outdir> <name> [<name> ...]
#
# The golden path is read out of the cell's OWN cmds.txt (never guessed), and a
# missing side prints SKIP and is COUNTED -- a driver that reaches nothing must
# never read as perfection.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CEN=$(dirname "$(readlink -f "$0")")/cen116.py
mkdir -p "$OUT"
skip=0; done=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "SKIP $n/$mode (g=${G:-none})"; skip=$((skip+1)); continue
      fi
      "$DUMP" "$G" 2>/dev/null > "$OUT/.g.dump"
      python3 "$CEN" "$OUT/.g.dump" "$n.$mode" > "$OUT/cen.g.$n.$mode.txt"
      "$DUMP" "$O" 2>/dev/null > "$OUT/.o.dump"
      python3 "$CEN" "$OUT/.o.dump" "$n.$mode" > "$OUT/cen.o.$n.$mode.txt"
      rm -f "$OUT/.g.dump" "$OUT/.o.dump"
      printf "%-14s %-9s golden=%-5s ours=%-5s\n" "$n" "$mode" \
        "$(wc -l < "$OUT/cen.g.$n.$mode.txt")" "$(wc -l < "$OUT/cen.o.$n.$mode.txt")"
      done=$((done+1))
    done
  done
done
echo "-- censused=$done SKIP=$skip"
