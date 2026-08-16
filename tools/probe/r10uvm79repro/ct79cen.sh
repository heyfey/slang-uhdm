#!/bin/bash
# r10uvm79repro/ct79cen.sh — run the census instrument over a WHOLE
# verify_golden workdir, on BOTH sides.
#
#   usage: ct79cen.sh <workdir> <outfile> [gold|ours|both]
#
# GUARDS (each one an ops trap this campaign has paid for), carried from
# r10uvm78repro/ct78cen.sh unchanged:
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
CEN=${R10UVM79CEN:-/tmp/r10uvm79cen}
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
  echo "-- $s hp=$(awk -v s=$s '$1=="TOTALS" && $2 ~ "^"s"/" {sub("hp=","",$3); t+=$3} END{print t+0}' "$OUT")" \
       "idxs=$(awk -v s=$s '$1=="TOTALS" && $2 ~ "^"s"/" {sub("idxs=","",$5); t+=$5} END{print t+0}' "$OUT")" \
       "e1=$(grep -c "^E1 $s/" "$OUT"; true)" \
       "e2=$(grep -c "^E2 $s/" "$OUT"; true)" \
       "e3=$(grep -c "^E3 $s/" "$OUT"; true)" \
       "e4=$(grep -c "^E4 $s/" "$OUT"; true)" \
       "e5=$(grep -c "^E5 $s/" "$OUT"; true)" \
       "e6=$(grep -c "^E6 $s/" "$OUT"; true)" \
       "e7=$(grep -c "^E7 $s/" "$OUT"; true)" \
       "dbE1=$(grep "^E1 $s/" "$OUT" | awk '{print $2}' | sort -u | wc -l)" \
       "dbE2=$(grep "^E2 $s/" "$OUT" | awk '{print $2}' | sort -u | wc -l)" \
       "dbE4=$(grep "^E4 $s/" "$OUT" | awk '{print $2}' | sort -u | wc -l)"
done
