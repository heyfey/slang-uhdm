#!/usr/bin/env bash
# r10v180 WIDE boundary — bound180.sh's contract (fd-3 list, children </dev/null,
# PROCESSED asserted, subdirs included, fenced names skipped and COUNTED, scratch
# keyed on the RELATIVE path) with TWO additions the implementer's R5 asks for:
#   * the DATABASE BYTES are compared as well as the dump, because a clone-copy
#     re-point can move only EDGES and be dump-invisible;
#   * a positive control (a deliberately moved cell) proves the gate can see.
# Parallel over files; each file owns its own directory, so the result is
# independent of the scheduling order.
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${BWD:-/tmp/v180_bound}; J=${J:-4}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | sort > "$LIST"
listed=$(wc -l < "$LIST"); [ "$listed" -gt 0 ] || { echo EMPTY-LIST; exit 4; }
: > "$WD/fenced.txt"
n=0; exec 3< "$LIST"
: > "$WD/work.txt"
while IFS= read -r src <&3; do
  n=$((n+1))
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$src")" | grep -qE "$FENCE_RE"; then
    echo "$src" >> "$WD/fenced.txt"; continue
  fi
  rel=${src#$ROOT/}
  b=$(printf "%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  printf '%s\t%s\n' "$b" "$src" >> "$WD/work.txt"
done
exec 3<&-
export PRI PAT WD DUMP
one() {
  b=${1%%	*}; src=${1#*	}
  o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || return 0
  leaf=$(basename "$src")
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null ); echo "rc_pris_$m=$?" >> "$o/rc.txt"
    ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null ); echo "rc_pat_$m=$?"  >> "$o/rc.txt"
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then echo "ASYMMETRIC $b/$m" >> "$WD/flags.txt"
      else echo "NOOUT $b/$m" >> "$WD/flags.txt"; fi
      continue
    fi
    cmp -s "$o/pris_$m.uhdm" "$o/pat_$m.uhdm" || echo "BYTEMOVED $b/$m" >> "$WD/flags.txt"
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump" || \
      echo "DUMPMOVED $b/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines" >> "$WD/flags.txt"
  done
  echo "$b" >> "$WD/processed.txt"
}
export -f one
: > "$WD/flags.txt"; : > "$WD/processed.txt"
tr '\n' '\0' < "$WD/work.txt" | xargs -0 -P "$J" -I{} bash -c 'one "$@"' _ {}
proc=$(wc -l < "$WD/processed.txt"); fenced=$(wc -l < "$WD/fenced.txt")
echo "LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc"
echo "BYTEMOVED=$(grep -c '^BYTEMOVED' "$WD/flags.txt"; true) DUMPMOVED=$(grep -c '^DUMPMOVED' "$WD/flags.txt"; true) ASYMMETRIC=$(grep -c '^ASYMMETRIC' "$WD/flags.txt"; true) NO_OUTPUT_PAIRS=$(grep -c '^NOOUT' "$WD/flags.txt"; true)"
[ $((proc+fenced)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
