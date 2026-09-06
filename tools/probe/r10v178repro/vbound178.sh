#!/usr/bin/env bash
# r10v178repro/vbound178.sh — the VERIFIER's WIDE boundary gate.  Descended
# from r10uvm178repro/bound178.sh with ONE change: each arm's scratch is
# removed as soon as it has been judged, so a 4899-source run cannot fill the
# VHDX (RESUME.md §9 / the 2026-08-24 disk incident).  Everything else is the
# same contract: fd-3 list, children </dev/null, PROCESSED asserted, recursive,
# both source suffixes, scratch keyed on the RELATIVE path.
set -u
PRI=${PRI:?}; PAT=${PAT:?}
ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${BWD:?}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | sort > "$LIST"
listed=$(wc -l < "$LIST")
[ "$listed" -gt 0 ] || { echo "EMPTY-LIST"; exit 4; }
n=0; moved=0; noout=0; fenced=0; proc=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  n=$((n+1))
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$src")" | grep -qE "$FENCE_RE"; then
    fenced=$((fenced+1)); continue
  fi
  rel=${src#$ROOT/}
  b=$(printf "%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
  leaf=$(basename "$src")
  proc=$((proc+1))
  keep=0
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null )
    ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null )
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
        echo "ASYMMETRIC_OUTPUT $b/$m"; moved=$((moved+1)); keep=1
      else
        noout=$((noout+1))
      fi
      continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    if ! cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump"; then
      echo "MOVED $b/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines"
      moved=$((moved+1)); keep=1
    fi
  done
  [ $keep -eq 1 ] || rm -rf "$o"
done
exec 3<&-
echo "LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ $((proc+fenced)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
