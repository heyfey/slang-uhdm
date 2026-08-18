#!/usr/bin/env bash
# v98 VERIFIER boundary — from a COPY of tools/probe, NO path filter, .sv AND
# .v, recursive PER-FILE arms *and* PER-DIRECTORY arms (every .sv/.v of one
# directory compiled together), fd-3 lists, children </dev/null, PROCESSED
# asserted, rc recorded and compared per cell, BOTH views.  Scratch keyed on the
# RELATIVE path (three arms are all named dut.sv).
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; WD=${BWD:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/files.txt; DLIST=$WD/dirs.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$LIST"
sed 's#/[^/]*$##' "$LIST" | sort -u > "$DLIST"
lf=$(wc -l < "$LIST"); ld=$(wc -l < "$DLIST")
[ "$lf" -gt 0 ] || { echo EMPTY-LIST; exit 4; }
n=0; proc=0; moved=0; noout=0; rcdiff=0; asym=0; fenced=0
run_cell(){ # $1 outdir  $2 tag  $3.. leaves
  local o=$1 tag=$2; shift 2
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl "$@" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > pris_$m.rc )
    ( cd "$o" && "$PAT" $fl "$@" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > pat_$m.rc )
    if ! cmp -s "$o/pris_$m.rc" "$o/pat_$m.rc"; then
      echo "RC_DIFF $tag/$m pris=$(cat "$o/pris_$m.rc") pat=$(cat "$o/pat_$m.rc")"
      rcdiff=$((rcdiff+1)); moved=$((moved+1))
    fi
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
        echo "ASYMMETRIC_OUTPUT $tag/$m"; asym=$((asym+1)); moved=$((moved+1))
      else noout=$((noout+1)); fi
      continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    if ! cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump"; then
      echo "MOVED $tag/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines"
      moved=$((moved+1))
    fi
  done
  rm -f "$o"/*.uhdm
}
exec 3< "$LIST"
while IFS= read -r src <&3; do
  n=$((n+1)); rel=${src#$ROOT/}
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$src")" | grep -qE "$FENCE_RE"; then
    fenced=$((fenced+1)); continue; fi
  b=$(printf "f%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
  proc=$((proc+1)); run_cell "$o" "$b" "$(basename "$src")"
done
exec 3<&-
dn=0; dproc=0
exec 4< "$DLIST"
while IFS= read -r d <&4; do
  dn=$((dn+1)); rel=${d#$ROOT}; rel=${rel#/}
  b=$(printf "d%04d_%s" "$dn" "$(echo "${rel:-ROOT}" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"
  leaves=""
  for f in "$d"/*.sv "$d"/*.v; do [ -f "$f" ] || continue; cp "$f" "$o/"; leaves="$leaves $(basename "$f")"; done
  [ -n "$leaves" ] || continue
  dproc=$((dproc+1)); run_cell "$o" "$b" $leaves
done
exec 4<&-
echo "FILES_LISTED=$lf FENCED_SKIPPED=$fenced FILES_PROCESSED=$proc"
echo "DIRS_LISTED=$ld DIRS_PROCESSED=$dproc"
echo "RC_PAIRS_COMPARED=$(( (proc+dproc)*2 ))  RC_DIFF=$rcdiff  ASYMMETRIC_OUTPUT=$asym"
echo "MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ $((proc+fenced)) -eq "$lf" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
