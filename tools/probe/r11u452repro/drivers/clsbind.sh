#!/bin/bash
# clsbind.sh <casedir> <tag> <kind> <name> <line>: class-owned <kind> <name>@<line> typespec bindings
# (instance + parent) golden vs ours; prints SAME or the diff
D=$(dirname $0); c=$(cd $1 && pwd); g=$($D/goldpath.sh $c)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); o=/tmp/r11u452_scr/out/$key/$2/ours.uhdm
R=/tmp/r11u452_bin/refts; [ -x $R ] || exit 2
f(){ $R $1 $3 $4 $5 | grep -A1 'class_defn' | grep -v '^--' ; }
d=$(diff <(f $g x $3 $4 $5) <(f $o x $3 $4 $5)); n=$(f $g x $3 $4 $5 | grep -c ts=)
[ -z "$d" ] && echo "$key $2 SAME ($n class vars)" || { echo "$key $2 DIFF"; echo "$d" | head -${N:-8}; }
