#!/bin/bash
# grid.sh <binary> <tag> [ENV=VAL ...] -> one line per grid cell (grid el runs with --elabuhdm on both sides)
D=$(cd "$(dirname "$0")" && pwd); bin=$1; tag=$2; shift 2
for c in $(ls -d $D/../grid/*/*/ | sort); do
  ex=""; case $c in */grid/el/*) ex=elab;; esac
  env "$@" bash $D/case.sh $c $bin $tag $ex
done
