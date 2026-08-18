#!/usr/bin/env bash
# v97 VERIFIER per-DIRECTORY boundary — every *repro* directory compiled as ONE
# arm (all its .sv/.v at once), both views, rc per cell.  Catches multi-file
# arms a per-file gate never assembles.
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${BWD:?}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/dirs.txt
find "$ROOT" -type d | sort > "$LIST"
listed=$(wc -l < "$LIST"); n=0; proc=0; moved=0; noout=0; rcdiff=0; asym=0; empty=0
exec 3< "$LIST"
while IFS= read -r d <&3; do
  n=$((n+1))
  files=$(find "$d" -maxdepth 1 \( -name '*.sv' -o -name '*.v' \) -type f | sort)
  [ -n "$files" ] || { empty=$((empty+1)); continue; }
  rel=${d#$ROOT/}
  b=$(printf "%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"
  leaves=""
  for f in $files; do cp "$f" "$o/" 2>/dev/null; leaves="$leaves $(basename "$f")"; done
  proc=$((proc+1))
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl $leaves -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > pris_$m.rc )
    ( cd "$o" && "$PAT" $fl $leaves -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > pat_$m.rc )
    cmp -s "$o/pris_$m.rc" "$o/pat_$m.rc" || { echo "RC_DIFF $b/$m $(cat "$o/pris_$m.rc")/$(cat "$o/pat_$m.rc")"; rcdiff=$((rcdiff+1)); moved=$((moved+1)); }
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then echo "ASYMMETRIC_OUTPUT $b/$m"; asym=$((asym+1)); moved=$((moved+1));
      else noout=$((noout+1)); fi
      continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump" || { echo "MOVED $b/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines"; moved=$((moved+1)); }
  done
  rm -f "$o"/*.uhdm
done
exec 3<&-
echo "DIRS_LISTED=$listed EMPTY=$empty PROCESSED=$proc RC_DIFF=$rcdiff ASYM=$asym MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ $((proc+empty)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
