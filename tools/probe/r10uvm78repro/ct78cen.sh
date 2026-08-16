#!/bin/bash
# r10uvm78repro/ct78cen.sh — run the census instrument over a WHOLE
# verify_golden workdir, on BOTH sides.
#
#   usage: ct78cen.sh <workdir> <outfile> [gold|ours|both]
#
# GUARDS (each one an ops trap this campaign has paid for):
#   * the golden path is read out of each test's OWN cmds.txt, so this script
#     cannot silently census the wrong golden, and the cache DIRECTORY is
#     turned into .../golden.uhdm (handing the tool a directory reads nothing).
#   * a side that is MISSING prints NOFILE and is COUNTED — a driver that
#     reached nothing must never read as perfection.
#   * the census tool prints a TOTALS line even on RESTORE_FAIL, and the
#     summary counts those separately.
#   * `grep -c` on a zero-match file exits 1 and would kill a `set -e` chain,
#     so every count is `; true`-terminated.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
SIDE=${3:-both}
CEN=${R10UVM78CEN:-/tmp/r10uvm78cen}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no census tool at $CEN"; exit 3; }
: > "$OUT"
n=0; nofile=0
for d in "$WD"/*/*/; do
  mode=$(basename "$(dirname "$d")")
  name=$(basename "$d")
  O=$d/slang.uhdm
  C=$d/cmds.txt
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ "$SIDE" = gold ] || [ "$SIDE" = both ]; then
    if [ -n "$G" ] && [ -f "$G" ]; then
      "$CEN" "$G" "GOLD/$mode/$name" >> "$OUT" 2>&1; n=$((n+1))
    else
      echo "NOFILE GOLD/$mode/$name" >> "$OUT"; nofile=$((nofile+1))
    fi
  fi
  if [ "$SIDE" = ours ] || [ "$SIDE" = both ]; then
    if [ -f "$O" ]; then
      "$CEN" "$O" "OURS/$mode/$name" >> "$OUT" 2>&1; n=$((n+1))
    else
      echo "NOFILE OURS/$mode/$name" >> "$OUT"; nofile=$((nofile+1))
    fi
  fi
done
echo "-- censused=$n NOFILE=$nofile"
echo "-- RESTORE_FAIL=$(grep -c RESTORE_FAIL "$OUT"; true)"
for s in GOLD OURS; do
  echo "-- $s sel=$(awk -v s=$s '$1=="TOTALS" && $2 ~ "^"s"/" {sub("sel=","",$3); t+=$3} END{print t+0}' "$OUT")" \
       "d2objs=$(grep -c "^D2 $s/" "$OUT"; true)" \
       "d3objs=$(grep -c "^D3 $s/" "$OUT"; true)" \
       "d4objs=$(grep -c "^D4 $s/" "$OUT"; true)" \
       "d5objs=$(grep -c "^D5 $s/" "$OUT"; true)" \
       "dbWithD2=$(grep "^D2 $s/" "$OUT" | awk '{print $2}' | sort -u | wc -l)" \
       "dbWithD3=$(grep "^D3 $s/" "$OUT" | awk '{print $2}' | sort -u | wc -l)" \
       "dbWithD5=$(grep "^D5 $s/" "$OUT" | awk '{print $2}' | sort -u | wc -l)"
done
