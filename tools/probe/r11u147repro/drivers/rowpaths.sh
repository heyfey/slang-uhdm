#!/bin/bash
# rowpaths.sh <workdir> <corpus> <mode> <test>: prints "<golden.uhdm> <ours.uhdm>" of a sweep row
d=$(ls -d $1/$2/$3/$4-* $1/$3/$4-* 2>/dev/null | head -1)
[ -z "$d" ] && exit 1
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
gf=$(ls $g/*.uhdm 2>/dev/null | head -1); [ -z "$gf" ] && gf=$(find $g -name '*.uhdm' | head -1)
echo $gf $d/slang.uhdm
