#!/usr/bin/env bash
set -u
ROOT=${CELLS:?}; OUT=${1:?}; shift
SL=$HOME/git-repos/Surelog/build/bin/surelog
SCAN=/tmp/vrgg9_gridscan
mkdir -p "$OUT"
nodb=0; noslang=0; cells=0; seg=0
args=("$@")
exec 3>"$OUT/CELLS.list"
for d in "$ROOT"/*/; do
  c=$(basename "$d"); w=$OUT/$c; mkdir -p "$w"; cells=$((cells+1)); echo "$c" >&3
  if [ ! -s "$w/gold.sites" ]; then
    (cd "$d" && "$SL" -parse dut.sv -mt 0 -mp 0 -o "$w" > "$w/sl.log" 2>&1 </dev/null)
    g=$(ls "$w"/slpp_all/*.uhdm 2>/dev/null | head -1)
    if [ -z "$g" ]; then echo "NODB $c"; nodb=$((nodb+1)); : > "$w/gold.sites"; continue; fi
    "$SCAN" "$g" > "$w/gold.sites" 2> "$w/gold.err"
  fi
  k=0
  while [ $k -lt ${#args[@]} ]; do
    bin=${args[$k]}; lbl=${args[$((k+1))]}
    (cd "$d" && "$bin" dut.sv --single-unit -o "$w/$lbl.uhdm" > "$w/$lbl.log" 2>&1 </dev/null)
    rc=$?; echo "$rc" > "$w/$lbl.rc"
    [ "$rc" = 139 ] && { seg=$((seg+1)); echo "SEGFAULT $c $lbl"; }
    if [ -s "$w/$lbl.uhdm" ]; then "$SCAN" "$w/$lbl.uhdm" > "$w/$lbl.sites" 2> "$w/$lbl.err"
    else echo "NOSLANG $c $lbl rc=$rc"; noslang=$((noslang+1)); : > "$w/$lbl.sites"; fi
    k=$((k+2))
  done
done
exec 3>&-
echo "-- cells=$cells NODB=$nodb NOSLANG=$noslang SEGFAULT=$seg"
