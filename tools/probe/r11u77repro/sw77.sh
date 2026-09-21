#!/usr/bin/env bash
# r11u77 SWITCH LEDGER.  usage: GRID=<dir> sw77.sh <patched-binary> <tag>
# Runs every arm under one environment setting and prints, per arm, the
# path-normalised dump distance from the PRISTINE database and from the
# PATCHED one.  Read it as "distance from pristine": `off` must be 0 on every
# arm, and each single switch must return exactly its own law's arms toward
# pristine and leave every other arm at the patched reading.
set -u
BIN=${1:?binary}; TAG=${2:?tag}
GRID=${GRID:?set GRID}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
for d0 in $GRID/*/; do
  d=${d0%/}                      # the glob's trailing slash breaks the
  a=$(basename $d)               # path normalisation below — strip it
  [ -f "$d/dut.sv" ] || continue
  ( cd $d && $BIN dut.sv --single-unit --nobuiltin -o sw.$TAG.uhdm > sw.$TAG.log 2>&1; echo "rc=$?" > swrc.$TAG.txt )
  [ -f $d/sw.$TAG.uhdm ] || { echo "$a NOFILE"; continue; }
  # The dump's first line names the .uhdm FILE, so normalise it away before
  # any cross-file compare (it is not a database byte).
  $DUMP $d/sw.$TAG.uhdm | sed -e "s#$d/##g" -e "s#^sw\.$TAG\.uhdm:#DB:#" > $d/sw.$TAG.dump 2>&1
  norm() { sed -e 's#^ours\.[a-z0-9]*\.uhdm:#DB:#' "$1" | sort; }
  dp=$(diff <(norm $d/ours.pris.dump) <(sort $d/sw.$TAG.dump) | grep -c '^[<>]'; true)
  dq=$(diff <(norm $d/ours.patch.dump) <(sort $d/sw.$TAG.dump) | grep -c '^[<>]'; true)
  echo "$a $(cat $d/swrc.$TAG.txt) vs_pristine=$dp vs_patched=$dq"
done
