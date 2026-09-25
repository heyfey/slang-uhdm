#!/bin/bash
# rowcmp.sh <sweepdir> <corpus> <mode> <test> [max]: strict records of one row (fence-guarded)
: ${FENCED:?}; for f in $FENCED; do [ "$f" = "$4" ] && { echo REFUSE; exit 2; }; done
d=$(ls -d $1/$2/$3/$4-* | head -1)
g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $NF}')
[ -d "$g" ] && g=$(find $g -name '*.uhdm' | head -1)
${STRICT_RAW:?build it with tools/probe/r11u167repro/drivers/mkstrictraw.sh} --max ${5:-6} $g $d/slang.uhdm
