#!/bin/bash
# r10rggen5uurun: run the unbased-unsized census on both sides and diff.
# Our constants carry no VpiFile (the census key strips the path on both sides).
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen5_slang.path)
/tmp/r10rggen5_uu "$G" | sed 's/^[^:]*:/:/' | sort > /tmp/r10rggen5_uug.txt
/tmp/r10rggen5_uu "$S" | sed 's/^[^:]*:/:/' | sort > /tmp/r10rggen5_uus.txt
diff /tmp/r10rggen5_uug.txt /tmp/r10rggen5_uus.txt > /tmp/r10rggen5_uu.diff
echo "rows g=$(wc -l < /tmp/r10rggen5_uug.txt) s=$(wc -l < /tmp/r10rggen5_uus.txt) diff=$(grep -c '^[<>]' /tmp/r10rggen5_uu.diff)"
head -${1:-40} /tmp/r10rggen5_uu.diff
