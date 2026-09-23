#!/bin/bash
# cen117.sh <out> <row>... — CENSUS on the SWEEP ROOTS (golden cache db, the
# pristine and the law sweep databases) of the named rows, both modes, with the
# golden-vs-golden calibration (the golden db listed twice must read 0) and
# the per-cell join: G=golden P=pristine L=law line presence per census cell.
OUT=${1:?}; shift; mkdir -p "$OUT"
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump; H=$(dirname "$0")
SW=${SW:-/tmp/r11u117_swp}
for row in "$@"; do for corp in u2r sl; do for m in default testflags; do
  pw=$(ls -d $SW/pris/$corp/$m/$row-* 2>/dev/null | head -1); [ -n "$pw" ] || continue
  lw=$SW/lawx/$corp/$m/$(basename "$pw")
  [ -f "$pw/slang.uhdm" ] || continue
  g=$(grep -o '/home[^)]*' "$pw/cmds.txt" | head -1)/golden.uhdm
  k="$OUT/$row.$m"
  for t in gold pris law; do
    case $t in gold) f=$g;; pris) f=$pw/slang.uhdm;; law) f=$lw/slang.uhdm;; esac
    timeout 1200 $D "$f" > "$k.$t.dump" 2>/dev/null; python3 "$H/cen117.py" "$k.$t.dump" > "$k.$t.cen"; rm -f "$k.$t.dump"
  done
  cal=$(diff "$k.gold.cen" "$k.gold.cen" | grep -c '^[<>]'; true)
  gp=$(diff "$k.gold.cen" "$k.pris.cen" | grep -c '^[<>]'; true)
  gl=$(diff "$k.gold.cen" "$k.law.cen" | grep -c '^[<>]'; true)
  pl=$(diff "$k.pris.cen" "$k.law.cen" | grep -c '^[<>]'; true)
  echo "$row $m cells=$(wc -l < "$k.gold.cen") cal=$cal gold-pris=$gp gold-law=$gl pris-law=$pl"
done; done; done
