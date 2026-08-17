#!/usr/bin/env bash
# vbuvm9 — boundary gate over an explicit LIST of arm sources (the shipped
# bndarms9.sh globs only <dir>/*.sv and therefore never reached the sd8 / sd9 /
# sd11 grids, whose arms live in SUBDIRECTORIES: grid6..grid11, qgrid4, ...).
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
same=0; moved=0; rej=0; one=0
while read -r src; do
  [ -f "$src" ] || continue
  key=$(echo "$src" | sed 's#.*/probe/##; s#/#_#g; s#\.sv$##')
  W=/tmp/vbuvm9_bnd2_$key
  rm -rf "$W"; mkdir -p "$W" || exit 3
  cp "$src" "$W/a.sv"
  (cd "$W" && "$PRISTINE" a.sv -o p.uhdm >p.log 2>&1)
  (cd "$W" && "$PATCHED"  a.sv -o q.uhdm >q.log 2>&1)
  if [ ! -f "$W/p.uhdm" ] && [ ! -f "$W/q.uhdm" ]; then
    printf "%-60s %-10s %s\n" "$key" - REJECT-BOTH; rej=$((rej+1)); continue; fi
  if [ ! -f "$W/p.uhdm" ] || [ ! -f "$W/q.uhdm" ]; then
    printf "%-60s %-10s %s\n" "$key" - "ONE-SIDE-ONLY(REGRESSION)"; one=$((one+1)); continue; fi
  if cmp -s "$W/p.uhdm" "$W/q.uhdm"; then same=$((same+1)); continue; fi
  (cd "$W" && "$SURELOG" -parse -nocache -mt 0 -mp 0 a.sv >sl.log 2>&1)
  hp=-; hq=-; lp=-; lq=-
  if [ -f "$W/slpp_all/surelog.uhdm" ]; then
    hp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>&1 | grep -c '^LHS:')
    hq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>&1 | grep -c '^LHS:')
    lp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>&1 | wc -l)
    lq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>&1 | wc -l)
  fi
  printf "%-60s %-10s heads %s->%s  cmplines %s -> %s\n" "$key" MOVED "$hp" "$hq" "$lp" "$lq"
  moved=$((moved+1))
done
echo "-- arms IDENTICAL=$same MOVED=$moved REJECT-BOTH=$rej ONE-SIDE=$one"
