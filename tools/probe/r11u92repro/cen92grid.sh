#!/usr/bin/env bash
# r11u92 CENSUS POSITIVE CONTROL — the same two traces, the same binary, on the
# GRID, so a corpus zero is a reading and not a dead instrument.
# usage: GRID=<dir> cen92grid.sh <binary>
# Columns: PROG = program homes reaching emitContAssigns, PDROP = LAW A's
# answer on them; NET = non-ANSI port nets reaching the module home's listing,
# NORD/NANCH = LAW B's two answers.  Arms with nothing to say are skipped.
set -u
BIN=${1:?binary}; GRID=${GRID:?set GRID}
printf '%-22s %5s %6s %5s %5s %6s\n' arm PROG PDROP NET NORD NANCH
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  err=$( cd $d && R11U92_CELLDBG=1 R11U92_NETDBG=1 $BIN dut.sv --single-unit \
           --nobuiltin -o /dev/null 2>&1 >/dev/null )
  pr=$(printf '%s\n' "$err" | grep -c '^R11U92PROG'; true)
  pd=$(printf '%s\n' "$err" | grep -c '^R11U92PROG .* drop=1'; true)
  nt=$(printf '%s\n' "$err" | grep -c '^R11U92NET'; true)
  no=$(printf '%s\n' "$err" | grep -c '^R11U92NET .* ord=1'; true)
  na=$(printf '%s\n' "$err" | grep -c '^R11U92NET .*anch=1'; true)
  [ "$pr$nt" = "00" ] && continue
  printf '%-22s %5s %6s %5s %5s %6s\n' "$a" "$pr" "$pd" "$nt" "$no" "$na"
done
