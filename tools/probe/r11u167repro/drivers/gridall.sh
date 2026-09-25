#!/bin/bash
# gridall.sh <pristine-bin> <law-bin> [ENV=VAL ...]: every case under ../cases through grid.sh for both
# binaries (tags P and L, the extra environment applied to the law run), one line per case:
# <case> <pristine verdict> -> <law verdict>.
D=$(cd $(dirname $0) && pwd); P=$1; L=$2; shift 2
for c in $(cd $D/../cases && ls -d */*/ | sed 's#/$##' | sort); do
  a=$($D/grid.sh $D/../cases/$c $P P | sed 's/.*strict=\([^ ]*\).*/\1/')
  b=$($D/grid.sh $D/../cases/$c $L L "$@" | sed 's/.*strict=\([^ ]*\).*/\1/')
  echo "$c $a -> $b"
done
