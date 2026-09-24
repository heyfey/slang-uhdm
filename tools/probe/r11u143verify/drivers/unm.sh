#!/bin/bash
# unm.sh <casekeydir> <P cfg> <L cfg>: runs unmask.py on the pair (symlinks under /tmp/r11u143_unm/<key>_<P>_<L>)
K=$(basename $1); D=/tmp/r11u143_unm/${K}_$2_$3; mkdir -p $D
for x in rec diffs; do ln -sf $1/$2.$x $D/P.$x; ln -sf $1/$3.$x $D/L.$x; done
ln -sf $1/g_$2.rec $D/g_P.rec; ln -sf $1/g_$3.rec $D/g_L.rec
python3 $(dirname $0)/unmask.py $D
