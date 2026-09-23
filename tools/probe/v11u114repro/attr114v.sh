#!/bin/bash
# order-blind attribution: <relpath> <A root> <B root> <outdir>
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
p=$1; A=$2; B=$3; O=$4; mkdir -p $O; k=$(echo $p | tr '/' '_')
for s in A B; do r=${!s}; timeout 900 $D $r/$p 2>/dev/null | sed -e "s#$r##g" -e 's/id:[0-9]*//g' | sort > $O/$k.$s.sorted; done
echo "$p orderblind_difflines=$(diff $O/$k.A.sorted $O/$k.B.sorted | grep -c '^[<>]'; true) sizeA=$(wc -l < $O/$k.A.sorted) sizeB=$(wc -l < $O/$k.B.sorted) bytes=$(stat -c %s $A/$p) $(stat -c %s $B/$p)"
