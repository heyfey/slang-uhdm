#!/usr/bin/env bash
# r10vearl121 -- THE GRID.  For each arm: build the golden BOTH ways with the
# harness Surelog (spelled in full -- earl120's R4), build ours with each frozen
# binary in each view, and print the per-cont_assign tagged_pattern count
# (`ntag`) cell by cell so golden / pristine / patched / fixed can be read off
# one line each.  MEASUREMENT ONLY; the judge is uhdm-cmp.
#
#   BINS="pris=/path/pris.bin patched=/path/patched.bin fixed=/path/fixed.bin" \
#   OUT=/tmp/vearl121_grid bash vgrid121.sh <arm.sv> [<arm.sv> ...]
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${OUT:?set OUT to a scratch dir}
BINS=${BINS:?set BINS to 'name=path ...'}
mkdir -p "$OUT"
ntag () {  # $1 = dump file
  python3 "$HERE/vcells121.py" "$1" elab \
    | grep -o 'line:[0-9]*:[0-9]*.*ntag=[0-9]*' \
    | sed 's/, endln.*ntag=/ ntag=/; s/nops=[0-9]* //' | sort -u | sort -V | tr '\n' ' '
}
for arm in "$@"; do
  b=$(basename "$arm"); n=${b%.sv}
  echo "===== $n"
  for view in plain elab; do
    case $view in plain) SF="";        UF="";;
                  elab)  SF="-elabuhdm"; UF="--elabuhdm";; esac
    d="$OUT/${n}_golden_$view"; rm -rf "$d"; mkdir -p "$d"; cp "$arm" "$d/"
    ( cd "$d" && "$SURELOG" -parse $SF -nobuiltin -nocache -sv -mt 0 -mp 0 -o w "$b" >sl.log 2>&1 </dev/null )
    echo "  golden rc=$? view=$view"
    g=$(ls "$d"/w/slpp_all/*.uhdm 2>/dev/null | head -1)
    [ -n "$g" ] && { "$DUMP" "$g" > "$d/dump" 2>/dev/null; echo "    golden : $(ntag "$d/dump")"; }
    for kv in $BINS; do
      k=${kv%%=*}; bin=${kv#*=}
      e="$OUT/${n}_${k}_$view"; rm -rf "$e"; mkdir -p "$e"; cp "$arm" "$e/"
      ( cd "$e" && "$bin" $UF "$b" -o slang.uhdm >slang.log 2>&1 </dev/null )
      rc=$?
      [ -f "$e/slang.uhdm" ] || { echo "    $k : NO-DB rc=$rc"; continue; }
      "$DUMP" "$e/slang.uhdm" > "$e/dump" 2>/dev/null
      echo "    $(printf '%-8s' "$k"): $(ntag "$e/dump")   rc=$rc"
    done
  done
done
