#!/usr/bin/env bash
# r10uvm106 wide boundary — PER-FILE and PER-DIRECTORY halves in one
# driver, from a COPY of tools/probe, NO path filter, .sv AND .v, recursive,
# BOTH views, rc per cell, list on fd 3, children </dev/null, PROCESSED
# asserted, scratch keyed on the RELATIVE path.
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; WD=${BWD:?}; MODE=${BMODE:-file}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/list.txt
if [ "$MODE" = file ]; then
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$LIST"
else
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f -printf '%h\n' | sort -u > "$LIST"
fi
listed=$(wc -l < "$LIST"); [ "$listed" -gt 0 ] || { echo EMPTY-LIST; exit 4; }
n=0; proc=0; moved=0; noout=0; rcdiff=0; asym=0; fenced=0
exec 3< "$LIST"
while IFS= read -r item <&3; do
  n=$((n+1))
  rel=${item#$ROOT/}
  b=$(printf "%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"
  if [ "$MODE" = file ]; then
    cp "$item" "$o/" || continue; args=$(basename "$item")
  else
    args=""; for f in "$item"/*.sv "$item"/*.v; do [ -f "$f" ] || continue; cp "$f" "$o/"; args="$args $(basename "$f")"; done
    [ -n "$args" ] || { rmdir "$o" 2>/dev/null; continue; }
  fi
  proc=$((proc+1))
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl $args -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > pris_$m.rc )
    ( cd "$o" && "$PAT" $fl $args -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > pat_$m.rc )
    cmp -s "$o/pris_$m.rc" "$o/pat_$m.rc" || { echo "RC_DIFF $b/$m pris=$(cat "$o/pris_$m.rc") pat=$(cat "$o/pat_$m.rc")"; rcdiff=$((rcdiff+1)); moved=$((moved+1)); }
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then echo "ASYM $b/$m"; asym=$((asym+1)); moved=$((moved+1));
      else noout=$((noout+1)); fi
      continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    if ! cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump"; then
      u=$(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true)
      s=$(diff <(sort "$o/pris_$m.dump") <(sort "$o/pat_$m.dump") | grep -cE '^[<>]'; true)
      echo "MOVED $b/$m unsorted=$u sorted=$s"
      moved=$((moved+1))
    fi
  done
  rm -f "$o"/*.uhdm
done
exec 3<&-
echo "MODE=$MODE LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout"
echo "RC_PAIRS=$((proc*2)) RC_DIFF=$rcdiff ASYM=$asym"
[ $((proc+fenced)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
