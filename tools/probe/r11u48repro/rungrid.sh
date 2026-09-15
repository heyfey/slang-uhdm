#!/bin/bash
# r11u48 — run every grid arm through BOTH producers and read the two shape
# listers on each.  Every arm records its rc from both tools; an arm whose
# compile fails teaches error recovery, not golden, and is reported as such.
#
#   GDIR=<grid dir> SLB=<slang-uhdm binary> OUT=<scratch dir> bash rungrid.sh
GDIR=${GDIR:?set GDIR}
SLB=${SLB:?set SLB}
OUT=${OUT:?set OUT}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
FC=${FC:?set FC}   # fcarg48 binary
RB=${RB:?set RB}   # rbnd48  binary
mkdir -p "$OUT"
shopt -s nullglob
files=("$GDIR"/*.sv)
echo "LISTED ${#files[@]}"
n=0
for f in "${files[@]}"; do
  b=$(basename "$f" .sv)
  d="$OUT/$b"; mkdir -p "$d"
  ( cd "$d" && "$SURELOG" -parse -d uhdm "$f" > sl.log 2>&1 </dev/null; echo $? > sl.rc )
  ( cd "$d" && "$SLB" "$f" --single-unit -o ours.uhdm > ours.log 2>&1 </dev/null; echo $? > ours.rc )
  grc=$(cat "$d/sl.rc"); orc=$(cat "$d/ours.rc")
  gdb="$d/slpp_all/surelog.uhdm"
  echo "== $b surelog_rc=$grc slang_rc=$orc gdb=$([ -f "$gdb" ] && echo yes || echo NO) odb=$([ -f "$d/ours.uhdm" ] && echo yes || echo NO)"
  if [ -f "$gdb" ]; then
    echo "-- GOLD FC"; "$FC" "$gdb" | grep '^FC' | sed 's/^/   /'
    echo "-- GOLD RB"; "$RB" "$gdb" | grep '^RB' | grep -E 'L=constant|R=constant' | sed 's/^/   /'
  fi
  if [ -f "$d/ours.uhdm" ]; then
    echo "-- OURS FC"; "$FC" "$d/ours.uhdm" | grep '^FC' | sed 's/^/   /'
    echo "-- OURS RB"; "$RB" "$d/ours.uhdm" | grep '^RB' | grep -E 'L=constant|R=constant' | sed 's/^/   /'
  fi
  if [ -f "$gdb" ] && [ -f "$d/ours.uhdm" ]; then
    "$HOME/git-repos/UHDM/build/bin/uhdm-cmp" "$gdb" "$d/ours.uhdm" > "$d/cmp.log" 2> "$d/cmp.head"
    echo "-- CMP rc=$? lines=$(wc -l < "$d/cmp.log") heads=$(grep -c '^LHS:' "$d/cmp.head"; true)"
  fi
  n=$((n+1))
done
echo "PROCESSED $n"
