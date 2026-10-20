#!/bin/bash
# away.sh <from-tag> <to-tag> <casedir>...: normalized dump lines differing from golden, <from> -> <to> (p pristine, l law, v verified)
f=$1; t=$2; shift 2
for c in "$@"; do
  a=$(bash $(dirname $0)/ddiff.sh $c $f | grep -c '^[<>]'); b=$(bash $(dirname $0)/ddiff.sh $c $t | grep -c '^[<>]')
  v=same; [ $b -lt $a ] && v=toward; [ $b -gt $a ] && v=AWAY
  echo "$(basename $(dirname $c))/$(basename $c) dump $a -> $b $v"
done
