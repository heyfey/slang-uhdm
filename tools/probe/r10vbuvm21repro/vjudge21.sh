#!/usr/bin/env bash
# r10vbuvm21repro/vjudge21.sh — THE OFFICIAL JUDGE on one arm, both views, for
# each named binary: `uhdm-cmp <golden> <ours>` line count (2>&1) and head count.
# This is the acceptance instrument; the censuses are measurement only.
#
# usage: vjudge21.sh <arm.sv> <outdir> <bin1> [bin2 ...]
set -u
ARM=$1; OUT=$2; shift 2
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
for v in def elab; do
  SUE=""; SLE=""; [ "$v" = elab ] && { SUE=-elabuhdm; SLE=--elabuhdm; }
  W="$OUT/$v"; rm -rf "$W"; mkdir -p "$W"; cp "$ARM" "$W/a.sv"
  ( cd "$W" && "$SURELOG" a.sv -parse $SUE -d coveruhdm -nocache -createcache \
       -noprecompiledcache -nowritecache -mt 0 -mp 0 -o w >sl.log 2>&1 ) </dev/null
  line="$(basename "$ARM") $v:"
  i=0
  for b in "$@"; do
    i=$((i+1))
    ( cd "$W" && "$b" a.sv $SLE -o "o$i.uhdm" >"o$i.log" 2>&1; echo "rc=$?" >>"o$i.log" ) </dev/null
    "$CMP" "$W/w/slpp_all/surelog.uhdm" "$W/o$i.uhdm" > "$W/c$i.txt" 2>&1
    n=$(grep -c '^' "$W/c$i.txt"; true); h=$(grep -c '^LHS:' "$W/c$i.txt"; true)
    line="$line  [$(basename "$b")] lines=$n heads=$h rc=$(grep -o 'rc=[0-9]*' "$W/o$i.log" | tail -1)"
  done
  echo "$line"
done
