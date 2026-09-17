#!/usr/bin/env bash
# r11u59 — order-blind, path-normalised whole-dump residue for one grid arm.
# usage: armdiff59.sh <armdir> <tag>   (needs gold.<tag>.dump / ours.<tag>.dump)
set -u
D=${1:?arm}; T=${2:?tag}
norm() { sed -e 's#/tmp/[^ ,)]*##g' -e 's/, id:[0-9]*//g' "$1" | sort; }
g=$(mktemp); o=$(mktemp)
norm $D/gold.$T.dump > $g; norm $D/ours.$T.dump > $o
echo "$(basename $D) $T golden-only=$(comm -23 $g $o | wc -l) ours-only=$(comm -13 $g $o | wc -l)"
rm -f $g $o
