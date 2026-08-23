#!/usr/bin/env bash
# r10uvm104 wide boundary, PER-DIRECTORY half (the per-FILE half is
# bound104.sh).  From a COPY of tools/probe, NO path filter, .sv AND .v,
# recursive; every directory that holds at least one source is compiled as ONE
# arm with all of its sources, so a law that only fires across files is not
# invisible.  fd-3 list, children </dev/null, PROCESSED asserted, rc per cell,
# both views.  Scratch is keyed on the RELATIVE path (three arms are dut.sv).
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; WD=${DBWD:?}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/dirs.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sed 's#/[^/]*$##' | sort -u > "$LIST"
listed=$(wc -l < "$LIST")
[ "$listed" -gt 0 ] || { echo EMPTY-LIST; exit 4; }
n=0; proc=0; moved=0; rcdiff=0; asym=0; noout=0
exec 3< "$LIST"
while IFS= read -r dir <&3; do
  n=$((n+1))
  rel=${dir#$ROOT/}
  b=$(printf "D%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"
  cp "$dir"/*.sv "$dir"/*.v "$o/" 2>/dev/null
  ls "$o" | grep -qE '\.(sv|v)$' || continue
  proc=$((proc+1))
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && shopt -s nullglob && src=(./*.sv ./*.v) && "$PRI" $fl "${src[@]}" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > pris_$m.rc )
    ( cd "$o" && shopt -s nullglob && src=(./*.sv ./*.v) && "$PAT" $fl "${src[@]}" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > pat_$m.rc )
    cmp -s "$o/pris_$m.rc" "$o/pat_$m.rc" || { echo "RC_DIFF $b/$m pris=$(cat $o/pris_$m.rc) pat=$(cat $o/pat_$m.rc)"; rcdiff=$((rcdiff+1)); moved=$((moved+1)); }
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
        echo "ASYMMETRIC_OUTPUT $b/$m"; asym=$((asym+1)); moved=$((moved+1))
      else
        noout=$((noout+1))
      fi
      rm -f "$o/pris_$m.uhdm" "$o/pat_$m.uhdm"; continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null | sed '1d' | sed "s#$o##g" > "$o/pris_$m.d"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null | sed '1d' | sed "s#$o##g" > "$o/pat_$m.d"
    if ! cmp -s "$o/pris_$m.d" "$o/pat_$m.d"; then
      echo "MOVED $b/$m $(diff "$o/pris_$m.d" "$o/pat_$m.d" | grep -c '^[<>]') lines"
      moved=$((moved+1))
    fi
    rm -f "$o/pris_$m.uhdm" "$o/pat_$m.uhdm" "$o/pris_$m.d" "$o/pat_$m.d"
  done
done
exec 3<&-
echo "DIRS_LISTED=$listed PROCESSED=$proc MOVED=$moved RC_DIFF=$rcdiff ASYM=$asym NO_OUTPUT=$noout"
[ "$proc" -gt 0 ] || { echo "PROCESSED-ZERO"; exit 5; }
