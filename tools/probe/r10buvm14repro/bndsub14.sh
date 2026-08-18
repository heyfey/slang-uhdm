#!/usr/bin/env bash
# r10buvm14repro/bndsub14.sh — boundary gate over an explicit LIST of arm
# sources read on STDIN (buvm9's bndsub9v.sh, whose lesson was that bndarms
# globs only <dir>/*.sv and therefore never reached the sd8..sd12 grids, whose
# arms live in SUBDIRECTORIES).
#
# FIXED HERE, AND IT MATTERED: the loop read the file list from STDIN and the
# two slang-uhdm invocations inside the loop ALSO read STDIN, so the FIRST
# invocation swallowed the entire list and the gate printed
# `IDENTICAL=0 MOVED=0 REJECT-BOTH=0 ONE-SIDE=0` over 455 arms — a GREEN LINE
# FROM A GATE THAT RAN NOTHING.  The list now travels on fd 3 and every child
# gets </dev/null.  Verified by asserting the processed count equals the input
# count.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
same=0; moved=0; rej=0; one=0; seen=0
while read -r src <&3; do
  # A PATH THAT DOES NOT RESOLVE IS FATAL, NOT SKIPPED.  It used to
  # `continue` silently, and a list of paths relative to a DIFFERENT cwd
  # therefore skipped all 455 arms and printed a green line.  Pass
  # ABSOLUTE paths.
  [ -f "$src" ] || { echo "FATAL: no such arm source: $src (pass ABSOLUTE paths)"; exit 8; }
  seen=$((seen+1))
  key=$(echo "$src" | sed 's#.*/probe/##; s#/#_#g; s#\.sv$##')
  W=/tmp/r10buvm14_bnd_$key
  rm -rf "$W"; mkdir -p "$W" || exit 3
  cp "$src" "$W/a.sv"
  (cd "$W" && "$PRISTINE" a.sv -o p.uhdm >p.log 2>&1 </dev/null)
  (cd "$W" && "$PATCHED"  a.sv -o q.uhdm >q.log 2>&1 </dev/null)
  if [ ! -f "$W/p.uhdm" ] && [ ! -f "$W/q.uhdm" ]; then
    printf "%-60s %-10s %s\n" "$key" - REJECT-BOTH; rej=$((rej+1)); continue; fi
  if [ ! -f "$W/p.uhdm" ] || [ ! -f "$W/q.uhdm" ]; then
    printf "%-60s %-10s %s\n" "$key" - "ONE-SIDE-ONLY(REGRESSION)"; one=$((one+1)); continue; fi
  if cmp -s "$W/p.uhdm" "$W/q.uhdm"; then same=$((same+1)); continue; fi
  (cd "$W" && "$SURELOG" -parse -nocache -mt 0 -mp 0 a.sv >sl.log 2>&1 </dev/null)
  hp=-; hq=-; lp=-; lq=-
  if [ -f "$W/slpp_all/surelog.uhdm" ]; then
    hp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>&1 | grep -c '^LHS:')
    hq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>&1 | grep -c '^LHS:')
    lp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>&1 | wc -l)
    lq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>&1 | wc -l)
  fi
  printf "%-60s %-10s heads %s->%s  cmplines %s -> %s\n" "$key" MOVED "$hp" "$hq" "$lp" "$lq"
  moved=$((moved+1))
done 3<&0
echo "-- arms PROCESSED=$seen IDENTICAL=$same MOVED=$moved REJECT-BOTH=$rej ONE-SIDE=$one"
[ "$seen" -gt 0 ] || { echo "FATAL: the gate processed NOTHING -- a green line here would be a lie"; exit 7; }
