#!/usr/bin/env bash
# v99 VERIFIER wide boundary: per-FILE and per-DIRECTORY arms, from a COPY of
# tools/probe, NO path filter, .sv AND .v, recursive, fd-3 list, children
# </dev/null, PROCESSED asserted, rc recorded per cell, both views.
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; WD=${BWD:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt; DLIST=$WD/dirs.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$LIST"
sed "s|/[^/]*$||" "$LIST" | sort -u > "$DLIST"
listed=$(wc -l < "$LIST"); dlisted=$(wc -l < "$DLIST")
[ "$listed" -gt 0 ] || { echo EMPTY-LIST; exit 4; }
n=0; moved=0; noout=0; fenced=0; proc=0; rcdiff=0; asym=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  n=$((n+1))
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$src")" | grep -qE "$FENCE_RE"; then
    fenced=$((fenced+1)); continue; fi
  rel=${src#$ROOT/}
  b=$(printf "F%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
  leaf=$(basename "$src"); proc=$((proc+1))
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > pris_$m.rc ) 2>/dev/null
    ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > pat_$m.rc ) 2>/dev/null
    cmp -s "$o/pris_$m.rc" "$o/pat_$m.rc" || { echo "RC_DIFF $b/$m pris=$(cat $o/pris_$m.rc) pat=$(cat $o/pat_$m.rc)"; rcdiff=$((rcdiff+1)); moved=$((moved+1)); }
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then echo "ASYMMETRIC_OUTPUT $b/$m"; asym=$((asym+1)); moved=$((moved+1));
      else noout=$((noout+1)); fi; continue; fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump" || { echo "MOVED FILE $b/$m $(diff $o/pris_$m.dump $o/pat_$m.dump | grep -cE '^[<>]'; true) lines"; moved=$((moved+1)); }
  done
  rm -f "$o"/*.uhdm
done
exec 3<&-
echo "FILE_ARMS: LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout RC_PAIRS=$((proc*2)) RC_DIFF=$rcdiff ASYM=$asym"
[ $((proc+fenced)) -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo "FILE-PROCESSED-ASSERT-OK"

# ---- per-DIRECTORY arms: every .sv/.v in one directory compiled TOGETHER ----
dn=0; dproc=0; dmoved=0; drc=0; dnoout=0; dasym=0
exec 4< "$DLIST"
while IFS= read -r d <&4; do
  dn=$((dn+1))
  rel=${d#$ROOT}; rel=${rel#/}
  b=$(printf "D%04d_%s" "$dn" "$(echo "${rel:-ROOT}" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"
  cnt=0
  for f in "$d"/*.sv "$d"/*.v; do
    [ -f "$f" ] || continue
    if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$f")" | grep -qE "$FENCE_RE"; then continue; fi
    cp "$f" "$o/" && cnt=$((cnt+1))
  done
  [ "$cnt" -gt 0 ] || continue
  dproc=$((dproc+1))
  leaves=$(cd "$o" && ls *.sv *.v 2>/dev/null | tr '\n' ' ')
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl $leaves -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > pris_$m.rc ) 2>/dev/null
    ( cd "$o" && "$PAT" $fl $leaves -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > pat_$m.rc ) 2>/dev/null
    cmp -s "$o/pris_$m.rc" "$o/pat_$m.rc" || { echo "DIR_RC_DIFF $b/$m pris=$(cat $o/pris_$m.rc) pat=$(cat $o/pat_$m.rc)"; drc=$((drc+1)); dmoved=$((dmoved+1)); }
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then echo "DIR_ASYMMETRIC $b/$m"; dasym=$((dasym+1)); dmoved=$((dmoved+1));
      else dnoout=$((dnoout+1)); fi; continue; fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump" || { echo "MOVED DIR $b/$m $(diff $o/pris_$m.dump $o/pat_$m.dump | grep -cE '^[<>]'; true) lines"; dmoved=$((dmoved+1)); }
  done
  rm -f "$o"/*.uhdm
done
exec 4<&-
echo "DIR_ARMS: LISTED=$dlisted PROCESSED=$dproc MOVED=$dmoved NO_OUTPUT_PAIRS=$dnoout RC_PAIRS=$((dproc*2)) RC_DIFF=$drc ASYM=$dasym"
echo DONE
