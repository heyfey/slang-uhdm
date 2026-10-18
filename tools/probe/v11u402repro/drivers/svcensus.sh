#!/bin/bash
# svcensus.sh <svwork> <binary> <outdir> : rerun every sv-tests slang command with R11U402_TRACE, print the laws that fired
W=$1; L=$2; O=$3; mkdir -p $O
find $W -name cmds.txt | sort > $O/list
one(){ c=$1; L=$2; O=$3; W=$4; rel=${c#$W/}; rel=${rel%/cmds.txt}; k=$(echo $rel | tr / _)
  cmd=$(grep '^slang:' $c | sed 's/^slang: *//'); [ -z "$cmd" ] && { echo "$rel | NOCMD"; return; }
  rest=$(echo "$cmd" | cut -d' ' -f2- | sed "s#-o [^ ]*#-o $O/x_$k.uhdm#"); t=$O/t_$k; rm -rf $t; mkdir -p $t/cwd
  (cd $t/cwd && eval "R11U402_TRACE=$t timeout 600 $L $rest" > /dev/null 2>&1; echo $? > $t/rc); rm -f $O/x_$k.uhdm
  f=$(cat $t/*.402 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s(%s) ", $2, $1}'); echo "$rel | rc=$(cat $t/rc) | ${f:--}"; rm -rf $t; }
export -f one
cat $O/list | xargs -P 3 -I{} bash -c "one {} $L $O $W"
