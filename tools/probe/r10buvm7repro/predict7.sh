#!/usr/bin/env bash
# r10buvm7 — THE PREDICTION.  Reads a PRISTINE sweep workdir, and for every
# (test,mode) with a database prints
#
#   <corpus>/<mode>/<test>  gold_WIDEREF=<n>  ours_PATH_at_those=<m>  VERDICT
#
# where WIDEREF is golden's collapsed inc/dec operand (a ref_obj spanning MORE
# than its own name) and ours_PATH_at_those counts, at THE SAME source
# positions, how many of ours are hier_paths.  VERDICT is
#   MOVER   golden has a collapse we do not build -> this database MUST move
#   CLEAN   no collapse anywhere in golden       -> this database MUST NOT move
#   AGREE   golden collapses and we already do   -> must not move
# and a row whose golden is MISSING prints NOGOLD and is COUNTED, because a
# predictor that reached nothing must never read as perfection.
#
#   usage: predict7.sh <pristine-workdir> <corpus-tag>
set -u
W=${1:?workdir}
TAG=${2:?corpus tag}
CEN=${R10BUVM7CEN:-/tmp/r10buvm7cen}
[ -x "$CEN" ] || { echo "FATAL: no census tool $CEN"; exit 3; }
mv=0; cl=0; ag=0; ng=0; nd=0
for d in "$W"/*/*/; do
  mode=$(basename "$(dirname "$d")")
  nm=$(basename "$d"); nm=${nm%-*}
  O=$d/slang.uhdm
  C=$d/cmds.txt
  [ -f "$O" ] || { nd=$((nd+1)); continue; }
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" 2>/dev/null | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    printf "%-14s %-9s %-40s NOGOLD\n" "$TAG" "$mode" "$nm"; ng=$((ng+1)); continue
  fi
  gw=$("$CEN" "$G" G | awk '/^INCDEC/ && $5=="WIDEREF"{print $3}' | sort -u)
  n=$(echo "$gw" | grep -c . ; true)
  if [ "$n" = 0 ]; then
    printf "%-14s %-9s %-40s gold_WIDEREF=0 CLEAN\n" "$TAG" "$mode" "$nm"; cl=$((cl+1)); continue
  fi
  ours=$("$CEN" "$O" O | awk '/^INCDEC/{print $3, $5}')
  m=0
  for p in $gw; do
    echo "$ours" | grep -q "^$p PATH$" && m=$((m+1))
  done
  if [ "$m" -gt 0 ]; then
    printf "%-14s %-9s %-40s gold_WIDEREF=%d ours_PATH=%d MOVER\n" "$TAG" "$mode" "$nm" "$n" "$m"; mv=$((mv+1))
  else
    printf "%-14s %-9s %-40s gold_WIDEREF=%d ours_PATH=0 AGREE\n" "$TAG" "$mode" "$nm" "$n"; ag=$((ag+1))
  fi
done
echo "-- $TAG MOVER=$mv CLEAN=$cl AGREE=$ag NOGOLD=$ng NO_DB=$nd"
