#!/usr/bin/env bash
# r11u84 SWITCH LEDGER.  usage: GRID=<dir> sw84.sh <binary> <tag> [ENV=1 ...]
#
# Rebuilds every arm's database under the given switch and reports its distance
# from the PRISTINE database and from the PATCHED one, TWICE:
#   *_blind  ORDER-BLIND (sorted)   -- what changed
#   *_ord    ORDER-SENSITIVE        -- and whether it MOVED
# A law whose whole surface is a SLOT (r11u84 LAW C) shows 0 in the blind
# column and its real size in the ordered one; scoring only the blind column
# would have read it as a no-op.  Both dumps are path-normalised AND
# banner-normalised (the dump prints the output file's own name), so the
# comparison is of the DATABASE and nothing else.
set -u
BIN=${1:?binary}; TAG=${2:?tag}; shift 2
GRID=${GRID:?set GRID}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
N='s#^[A-Za-z0-9._]*\.uhdm: #DB: #'
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  [ -f "$d/ours.pris.dump" ] && [ -f "$d/ours.p1.dump" ] || continue
  ( cd $d && env "$@" $BIN dut.sv --single-unit --nobuiltin -o sw.$TAG.uhdm \
      > sw.$TAG.log 2>&1; echo $? > sw.$TAG.rc )
  [ -f $d/sw.$TAG.uhdm ] || { echo "$a NODB rc=$(cat $d/sw.$TAG.rc)"; continue; }
  $DUMP $d/sw.$TAG.uhdm | sed -e "s#$d/##g" -e "$N" > $d/sw.$TAG.norm
  sed -e "$N" $d/ours.pris.dump > $d/pris.norm
  sed -e "$N" $d/ours.p1.dump   > $d/p1.norm
  for f in sw.$TAG pris p1; do sort $d/$f.norm > $d/$f.sorted; done
  vpb=$(diff $d/pris.sorted $d/sw.$TAG.sorted | grep -c '^[<>]'; true)
  vab=$(diff $d/p1.sorted   $d/sw.$TAG.sorted | grep -c '^[<>]'; true)
  vpo=$(diff $d/pris.norm   $d/sw.$TAG.norm   | grep -c '^[<>]'; true)
  vao=$(diff $d/p1.norm     $d/sw.$TAG.norm   | grep -c '^[<>]'; true)
  echo "$a pris_blind=$vpb pris_ord=$vpo patch_blind=$vab patch_ord=$vao rc=$(cat $d/sw.$TAG.rc)"
done
