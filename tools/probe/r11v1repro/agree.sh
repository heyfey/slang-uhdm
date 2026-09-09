#!/bin/bash
# r11v1 — THE ANTI-REGRESSION SCORER for § ifacePortViewParamAssignsOnly.
#
#   usage: agree.sh <pristine-workdir> <patched-workdir> <name>...
#
# For every named test it builds the interface_inst parameter census of GOLDEN,
# of the PRISTINE database and of the PATCHED one (r11u1repro/ifcen.py), then
# reports, per test:
#
#   agree_pris  census rows the PRISTINE database shares with golden
#   agree_pat   census rows the PATCHED  database shares with golden
#   LOST        rows that agreed with golden BEFORE and DO NOT AFTER
#
# LOST is the number that convicts: a nonzero LOST is a real regression on a
# face the judge reads, no matter what the CSV status or the cmp LINE COUNT
# does.  Rggen is why this exists — its cmp output grew 531 -> 801 lines under
# the law while its census agreement grew 1170 -> 1837 with LOST=0; the line
# count rose only because a vector MISMATCH prints the whole golden vector.
#
# A raw sorted-dump multiset diff must NOT be used for this: an object golden
# has and we never emit (a 2-D interface array element) donates lines that our
# DELETED port-view parameter objects used to match by accident, so removing a
# wrong object reads as a loss.  Measured: an arm with a 2-D interface array
# scored LOST=35, and the same arm with the array removed scored LOST=0.
set -u
P=${1:?pristine workdir}; Q=${2:?patched workdir}; shift 2
HERE=$(dirname "$(readlink -f "$0")")
CEN="$HERE/../r11u1repro/cen.sh"
[ -x "$CEN" ] || [ -f "$CEN" ] || { echo "FATAL: missing $CEN"; exit 9; }
OP=$(mktemp -d); OQ=$(mktemp -d)
bash "$CEN" "$P" "$OP" "$@" > /dev/null 2>&1
bash "$CEN" "$Q" "$OQ" "$@" > /dev/null 2>&1
printf "%-36s %6s %6s %6s\n" TEST agree_p agree_q LOST
tot=0; seen=0
for n in "$@"; do
  if [ ! -f "$OP/$n.g.cen" ] || [ ! -f "$OQ/$n.g.cen" ]; then
    printf "%-36s %6s %6s %6s\n" "$n" - - SKIP-NOFILE; continue
  fi
  # the golden census must be the SAME on both sides or the comparison is void
  if ! cmp -s "$OP/$n.g.cen" "$OQ/$n.g.cen"; then
    printf "%-36s %6s %6s %6s\n" "$n" - - GOLDEN-MISMATCH; continue
  fi
  ap=$(comm -12 "$OP/$n.g.cen" "$OP/$n.o.cen" | grep -c . ; true)
  aq=$(comm -12 "$OQ/$n.g.cen" "$OQ/$n.o.cen" | grep -c . ; true)
  lost=$(comm -23 <(comm -12 "$OP/$n.g.cen" "$OP/$n.o.cen") \
                  <(comm -12 "$OQ/$n.g.cen" "$OQ/$n.o.cen") | grep -c . ; true)
  printf "%-36s %6s %6s %6s\n" "$n" "$ap" "$aq" "$lost"
  [ "$lost" != "0" ] && comm -23 <(comm -12 "$OP/$n.g.cen" "$OP/$n.o.cen") \
                                 <(comm -12 "$OQ/$n.g.cen" "$OQ/$n.o.cen") | sed 's/^/    LOST /'
  tot=$((tot+lost)); seen=$((seen+1))
done
echo "---- scored=$seen  TOTAL-LOST=$tot"
[ "$seen" = 0 ] && { echo "FAIL: nothing scored (a zero here is NOT a pass)"; exit 8; }
[ "$tot" = 0 ] && echo "PASS: no census row that agreed with golden stopped agreeing." \
               || echo "FAIL: rows moved AWAY from golden -- read them above."
rm -rf "$OP" "$OQ"
