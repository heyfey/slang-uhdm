#!/bin/bash
# scorearm109.sh <armdir> <tagA> <tagB> [-v]: dump gold/A/B (grid109.sh layout) and score cells A->B (cells109.py)
d=$1; a=$2; b=$3; D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump; H=$(dirname "$(readlink -f "$0")")
for t in gold $a $b; do [ -f $d/$t.uhdm ] && $D $d/$t.uhdm > $d/$t.dump 2>&1; done
python3 $H/cells109.py $d/gold.dump $d/$a.dump $d/$b.dump $4
