#!/usr/bin/env bash
# r10uvm139 — ORDER-BLIND MOVER ATTRIBUTION.  MEASUREMENT ONLY.
#
# For each named row, dumps the PRISTINE and the PATCHED `slang.uhdm`, strips
# the ids and the workdir path (a dump embeds both), LC_ALL=C-sorts both sides
# and diffs them.  Sorting is the only sound attribution for Scoreboard/default
# and SeqDriver, which are ~50/50 COINS per invocation (RESUME.md §9).
#
# The sorted diff reports the NET line delta (identical dump lines cancel in a
# multiset diff), so a SECOND, NAMED attribution runs beside it: ct139cen's
# variable census, whose rows carry the object's scope and name, is diffed
# per row and every differing census row must be an AUTO= flip.
#
#   PRIS=<pristine workdir> PAT=<patched workdir> CEN=<ct139cen> movers139.sh <row> …
set -u
PRIS=${PRIS:?set PRIS=<pristine sweep workdir>}
PAT=${PAT:?set PAT=<patched sweep workdir>}
OUT=${OUT:-/tmp/r10uvm139_movers}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CEN:?set CEN=<ct139cen binary>}
mkdir -p "$OUT"
tot=0; unattr=0
printf "%-14s %-9s %10s %10s %s\n" ROW MODE DIFFLINES UNATTRIB NOTE
for n in "$@"; do
  for mode in default testflags; do
    for d in "$PRIS/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      a=$PRIS/$mode/$b/slang.uhdm; c=$PAT/$mode/$b/slang.uhdm
      [ -f "$a" ] && [ -f "$c" ] || { printf "%-14s %-9s %10s %10s %s\n" "$n" "$mode" - - SKIP-NOFILE; continue; }
      o=$OUT/$n.$mode; mkdir -p "$o"
      for s in pris:$a pat:$c; do
        "$DUMP" "${s#*:}" 2>/dev/null </dev/null \
          | sed -e 's#, id:[0-9]*##g' -e "s#/tmp/[^ ,]*/slang.uhdm##g" \
          | LC_ALL=C sort > "$o/${s%%:*}.norm"
      done
      "$CEN" "$a" > "$o/pris.cen" 2>/dev/null </dev/null
      "$CEN" "$c" > "$o/pat.cen"  2>/dev/null </dev/null
      diff <(sed 's/^AUTO=[01]|//' "$o/pris.cen") \
           <(sed 's/^AUTO=[01]|//' "$o/pat.cen") > "$o/cen_noauto.diff"
      cnb=$(grep -c '^[<>]' "$o/cen_noauto.diff"); true
      diff "$o/pris.cen" "$o/pat.cen" > "$o/cen.diff"
      cna=$(grep -c '^[<>]' "$o/cen.diff"); true
      grep '^[<>]' "$o/cen.diff" | sed 's/^..//' | sed 's/^AUTO=[01]|VKIND=[^|]*|VNAME=/ /;s/|.*//' \
        | sort -u > "$o/moved_names.txt"
      diff "$o/pris.norm" "$o/pat.norm" > "$o/norm.diff"
      n1=$(grep -c '^[<>]' "$o/norm.diff"); true
      # every differing line must be a vpiAutomatic stamp
      n2=$(grep '^[<>]' "$o/norm.diff" | grep -vc 'vpiAutomatic'); true
      tot=$((tot+n1)); unattr=$((unattr+n2))
      unattr=$((unattr+cnb))
      printf "%-14s %-9s %10s %10s %s\n" "$n" "$mode" "$n1" "$((n2+cnb))" \
        "cenrows=$cna outside-AUTO=$cnb names=[$(tr '\n' ' ' < "$o/moved_names.txt")]"
    done
  done
done
echo "-- total differing lines=$tot  unattributed=$unattr"
[ "$unattr" -eq 0 ] && echo "ATTRIBUTION COMPLETE" || { echo "ATTRIBUTION INCOMPLETE"; exit 5; }
