#!/usr/bin/env bash
# v11u93 DATABASE CENSUS, GOLDEN FIRST: every golden (golden-cache hash from each
# cmds.txt) AND every slang.uhdm of one sweep workdir is restored by ct101cen and
# every scoped (`work@<outer>::<inner>`) AllModules entry is printed.
# usage: CT=<ct101cen> [S=<scratch>] dbcenv93.sh <sweep workdir> <tag>
set -u
CT=${CT:?path to a built ct101cen (tools/probe/r11u101repro/ct101cen.cpp)}; S=${S:-/tmp/v11u93_scr}; mkdir -p $S
W=$1; T=$2
for cm in $(find $W -name cmds.txt | sort); do
  h=$(grep -o 'golden cache [a-z]* [^ )]*' $cm | awk '{print $NF}' | head -1)
  [ -n "$h" ] && [ -f $h/golden.uhdm ] && echo $h/golden.uhdm
done | sort -u > $S/gl_$T.txt
find $W -name slang.uhdm | sort > $S/ol_$T.txt
echo "cmds=$(find $W -name cmds.txt | wc -l) goldens=$(wc -l < $S/gl_$T.txt) ours=$(wc -l < $S/ol_$T.txt)"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
$CT < $S/gl_$T.txt > $S/gcen_$T.gold.txt 2>&1
$CT < $S/ol_$T.txt > $S/gcen_$T.ours.txt 2>&1
tail -1 $S/gcen_$T.gold.txt; tail -1 $S/gcen_$T.ours.txt
