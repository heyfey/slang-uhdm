#!/bin/bash
# rowunmask.sh <corpus> <mode> <test> <P workdir> <L workdir>: strict records golden vs P (law off) and golden vs L (law on),
# then unmask.py (every field L differs on that P did not report: WORSE before P's divergence / UNMASKED / WORSE past it)
c=$1; m=$2; t=$3; P=$4; L=$5
dp=$(ls -d $P/$c/$m/$t-* | head -1); dl=$(ls -d $L/$c/$m/$t-* | head -1)
g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' $dl/cmds.txt)/golden.uhdm
D=/tmp/r11u143_unm/row_${t}_${m}_$(basename $P)_$(basename $L); mkdir -p $D
X=/tmp/r11u143_bin/strictx
$X --max 0 --diffs $D/P.diffs --dump-a $D/g_P.rec --dump-b $D/P.rec $g $dp/slang.uhdm > $D/P.out 2>&1
$X --max 0 --diffs $D/L.diffs --dump-a $D/g_L.rec --dump-b $D/L.rec $g $dl/slang.uhdm > $D/L.out 2>&1
echo "== $c/$m/$t  P: $(tail -1 $D/P.out)  L: $(tail -1 $D/L.out)"
python3 $(dirname $0)/unmask.py $D
