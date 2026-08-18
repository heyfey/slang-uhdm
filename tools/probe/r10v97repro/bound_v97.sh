#!/usr/bin/env bash
# v97 VERIFIER wide boundary — from a COPY of tools/probe, NO path filter,
# .sv AND .v, recursive, per-file AND per-directory arms, fd-3 list, children
# </dev/null, PROCESSED asserted, rc recorded per cell, both views.
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${BWD:?}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$LIST"
listed=$(wc -l < "$LIST")
[ "$listed" -gt 0 ] || { echo "EMPTY-LIST"; exit 4; }
n=0; moved=0; noout=0; fenced=0; proc=0; rcdiff=0; asym=0
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
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > pris_$m.rc )
    ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > pat_$m.rc )
    if ! cmp -s "$o/pris_$m.rc" "$o/pat_$m.rc"; then
      echo "RC_DIFF $b/$m pris=$(cat "$o/pris_$m.rc") pat=$(cat "$o/pat_$m.rc")"
      rcdiff=$((rcdiff+1)); moved=$((moved+1))
    fi
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
        echo "ASYMMETRIC_OUTPUT $b/$m"; asym=$((asym+1)); moved=$((moved+1))
      else
        noout=$((noout+1))
      fi
      continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    if ! cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump"; then
      echo "MOVED $b/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines"
      moved=$((moved+1))
    fi
  done
  rm -f "$o"/*.uhdm
done
exec 3<&-
echo "RC_PAIRS_COMPARED=$((proc*2))  RC_DIFF=$rcdiff  ASYMMETRIC_OUTPUT=$asym"
echo "LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ $((proc+fenced)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
