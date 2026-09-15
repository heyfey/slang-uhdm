#!/bin/bash
# r11v48 verifier grid runner. GDIR/SLB/OUT/TAG from env; nothing hard-coded
# outside this pass's own scratch.
GDIR=${GDIR:?}; SLB=${SLB:?}; OUT=${OUT:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
FC=${FC:-/tmp/v11u48_bin/fcarg48}
RB=${RB:-/tmp/v11u48_bin/rbnd48}
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
mkdir -p "$OUT"; shopt -s nullglob
files=("$GDIR"/*.sv)
echo "LISTED ${#files[@]}"
n=0
for f in "${files[@]}"; do
  b=$(basename "$f" .sv); d="$OUT/$b"; mkdir -p "$d"
  if [ ! -f "$d/slpp_all/surelog.uhdm" ]; then
    ( cd "$d" && "$SURELOG" -parse -d uhdm "$f" > sl.log 2>&1 </dev/null; echo $? > sl.rc )
  fi
  ( cd "$d" && "$SLB" "$f" --single-unit -o ours.uhdm > ours.log 2>&1 </dev/null; echo $? > ours.rc )
  grc=$(cat "$d/sl.rc" 2>/dev/null); orc=$(cat "$d/ours.rc")
  g="$d/slpp_all/surelog.uhdm"
  echo "== $b surelog_rc=$grc slang_rc=$orc gdb=$([ -f "$g" ] && echo yes || echo NO) odb=$([ -f "$d/ours.uhdm" ] && echo yes || echo NO)"
  if [ -f "$g" ]; then
    echo "-- GOLD FC"; "$FC" "$g" | grep '^FC' | sed 's/^/   /'; true
    echo "-- GOLD RB"; "$RB" "$g" | grep '^RB' | sed 's/^/   /'; true
  fi
  if [ -f "$d/ours.uhdm" ]; then
    echo "-- OURS FC"; "$FC" "$d/ours.uhdm" | grep '^FC' | sed 's/^/   /'; true
    echo "-- OURS RB"; "$RB" "$d/ours.uhdm" | grep '^RB' | sed 's/^/   /'; true
  fi
  if [ -f "$g" ] && [ -f "$d/ours.uhdm" ]; then
    "$CMP" "$g" "$d/ours.uhdm" > "$d/cmp.log" 2> "$d/cmp.head"; rc=$?
    echo "-- CMP rc=$rc lines=$(wc -l < "$d/cmp.log") heads=$(grep -c '^LHS:' "$d/cmp.head"; true)"
  fi
  n=$((n+1))
done
echo "PROCESSED $n"
