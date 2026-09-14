#!/usr/bin/env bash
# r11u21 golden grid: Surelog v1.87 golden + the PRISTINE and PATCHED binaries,
# one arm per directory, EVERY ARM'S rc RECORDED (a rc=139 reads as
# SLANG_REJECT in the sweep harness, and an arm whose compile failed teaches
# error recovery, not golden).
#   usage: PRIS=<bin> PAT=<bin> [G=<grid root>] grid.sh a1 a2 ...
set -u
G=${G:-$(cd "$(dirname "$0")" && pwd)}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
UC=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
PRIS=${PRIS:?set PRIS to the pristine binary}
PAT=${PAT:?set PAT to the patched binary}
for d in "$@"; do
  dir=$G/$d
  [ -d "$dir" ] || { echo "$d NODIR"; continue; }
  rm -rf "$dir/gold" "$dir"/*.uhdm "$dir"/*.log "$dir"/*.dump "$dir"/*.err "$dir"/*.cmp
  mkdir -p "$dir/gold"
  ( cd "$dir" && "$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 \
      -o "$dir/gold" > "$dir/sl.log" 2>&1 )
  slrc=$?
  g=$(find "$dir/gold" -name 'surelog.uhdm' 2>/dev/null | head -1)
  ( cd "$dir" && "$PRIS" dut.sv --single-unit --nobuiltin -o "$dir/pris.uhdm" \
      > "$dir/pris.log" 2>&1 ); prc=$?
  ( cd "$dir" && "$PAT"  dut.sv --single-unit --nobuiltin -o "$dir/pat.uhdm" \
      > "$dir/pat.log"  2>&1 ); qrc=$?
  ph=NA; qh=NA; pl=NA; ql=NA
  [ -n "$g" ] && "$UD" "$g" > "$dir/gold.dump" 2>/dev/null
  if [ -n "$g" ] && [ -f "$dir/pris.uhdm" ]; then
    "$UD" "$dir/pris.uhdm" > "$dir/pris.dump" 2>/dev/null
    "$UC" "$g" "$dir/pris.uhdm" > "$dir/pris.cmp" 2> "$dir/pris.err"
    pl=$(wc -l < "$dir/pris.cmp"); ph=$(grep -c '^LHS:' "$dir/pris.err"; true)
  fi
  if [ -n "$g" ] && [ -f "$dir/pat.uhdm" ]; then
    "$UD" "$dir/pat.uhdm" > "$dir/pat.dump" 2>/dev/null
    "$UC" "$g" "$dir/pat.uhdm" > "$dir/pat.cmp" 2> "$dir/pat.err"
    ql=$(wc -l < "$dir/pat.cmp"); qh=$(grep -c '^LHS:' "$dir/pat.err"; true)
  fi
  err=$(grep -m1 'ERROR\] :' "$dir/sl.log" 2>/dev/null | tr -s ' ')
  echo "$d slrc=$slrc [$err] gold=$([ -n "$g" ] && echo yes || echo NO) pris_rc=$prc pat_rc=$qrc PRIS[heads=$ph lines=$pl] PAT[heads=$qh lines=$ql]"
done
