#!/usr/bin/env bash
# vrgg8 runner: real Surelog + N slang binaries per cell, with EXPLICIT rc
# capture so a SEGFAULT is its own category and never reads as agreement.
set -u
CELLS=${CELLS:?cells dir}
OUT=${1:?outdir}
shift || true
SL=$HOME/git-repos/Surelog/build/bin/surelog
SCAN=${GRIDSCAN:-/tmp/vrgg8_gridscan}
[ -x "$SL" ] || { echo "FATAL: no surelog"; exit 3; }
[ -x "$SCAN" ] || { echo "FATAL: no gridscan"; exit 3; }
mkdir -p "$OUT"
nodb=0; noslang=0; crash=0; cells=0
args=("$@")
for d in "$CELLS"/*/; do
  c=$(basename "$d"); w=$OUT/$c; mkdir -p "$w"; cells=$((cells+1))
  if [ ! -s "$w/gold.sites" ]; then
    (cd "$d" && timeout 300 "$SL" -parse dut.sv -mt 0 -mp 0 -o "$w" > "$w/sl.log" 2>&1)
    g=$(ls "$w"/slpp_all/*.uhdm 2>/dev/null | head -1)
    if [ -z "$g" ]; then echo "NODB $c"; nodb=$((nodb+1)); : > "$w/gold.sites";
    else "$SCAN" "$g" > "$w/gold.sites" 2> "$w/gold.err"; fi
  fi
  k=0
  while [ $k -lt ${#args[@]} ]; do
    bin=${args[$k]}; lbl=${args[$((k+1))]}
    (cd "$d" && timeout 120 "$bin" dut.sv --single-unit -o "$w/$lbl.uhdm" > "$w/$lbl.log" 2>&1)
    rc=$?
    echo "$rc" > "$w/$lbl.rc"
    if [ $rc -ge 128 ]; then echo "CRASH $c $lbl rc=$rc"; crash=$((crash+1)); fi
    if [ -s "$w/$lbl.uhdm" ]; then
      "$SCAN" "$w/$lbl.uhdm" > "$w/$lbl.sites" 2> "$w/$lbl.err"
    else
      echo "NOSLANG $c $lbl rc=$rc"; noslang=$((noslang+1)); : > "$w/$lbl.sites"
    fi
    k=$((k+2))
  done
done
echo "-- cells=$cells NODB=$nodb NOSLANG=$noslang CRASH=$crash"
