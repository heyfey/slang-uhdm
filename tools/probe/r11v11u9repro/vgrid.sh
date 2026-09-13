#!/usr/bin/env bash
# v11u9 golden grid: surelog v1.87 golden + pristine + patched, per arm, rc recorded.
set -u
G=${G:-$(cd "$(dirname "$0")" && pwd)}
SL=$HOME/git-repos/Surelog/build/bin/surelog
UD=$HOME/git-repos/UHDM/build/bin/uhdm-dump
UC=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
PRIS=${PRIS:?set PRIS to the pristine binary}
PAT=${PAT:?set PAT to the patched binary}
for d in "$@"; do
  dir=$G/$d
  [ -d "$dir" ] || { echo "$d NODIR"; continue; }
  rm -rf "$dir/gold" "$dir"/*.uhdm "$dir"/*.log
  mkdir -p "$dir/gold"
  ( cd "$dir" && "$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$dir/gold" > "$dir/sl.log" 2>&1 )
  slrc=$?
  g=$(find "$dir/gold" -name 'surelog.uhdm' 2>/dev/null | head -1)
  ( cd "$dir" && "$PRIS" dut.sv --single-unit --nobuiltin -o "$dir/pris.uhdm" > "$dir/pris.log" 2>&1 ); prc=$?
  ( cd "$dir" && "$PAT"  dut.sv --single-unit --nobuiltin -o "$dir/pat.uhdm"  > "$dir/pat.log"  2>&1 ); qrc=$?
  ph="NA"; qh="NA"; pl="NA"; ql="NA"
  if [ -n "$g" ] && [ -f "$dir/pris.uhdm" ]; then
    "$UC" "$g" "$dir/pris.uhdm" > "$dir/pris.cmp" 2> "$dir/pris.err"; pl=$(wc -l < "$dir/pris.err"); ph=$(grep -c '^LHS:' "$dir/pris.err"; true)
  fi
  if [ -n "$g" ] && [ -f "$dir/pat.uhdm" ]; then
    "$UC" "$g" "$dir/pat.uhdm" > "$dir/pat.cmp" 2> "$dir/pat.err"; ql=$(wc -l < "$dir/pat.err"); qh=$(grep -c '^LHS:' "$dir/pat.err"; true)
  fi
  echo "$d slrc=$slrc gold=$([ -n "$g" ] && echo yes || echo NO) pris_rc=$prc pat_rc=$qrc PRIS[heads=$ph lines=$pl] PAT[heads=$qh lines=$ql]"
done
