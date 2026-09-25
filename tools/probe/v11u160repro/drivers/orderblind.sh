#!/bin/bash
# ob.sh <sweep corpus root(pris)> <rel dir> <pris db> <law db>: order-blind multiset overlap with golden
source $(dirname $0)/env.sh
d=$2; c=$(grep -o 'goldens/[0-9a-f]*' $1/$d/cmds.txt | head -1); g=$HOME/.cache/slang-uhdm-goldens/${c#goldens/}/golden.uhdm
t=/tmp/v11u160_ob_$$; mkdir -p $t
norm(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's#/tmp/[^ ]*/slang\.uhdm##; s#[0-9]+\) *$##' | sed -E 's/^[ |\\_-]*//' | sort; }
norm $g > $t/g; norm $3 > $t/p; norm $4 > $t/l
gp=$(comm -12 $t/g $t/p | wc -l); gl=$(comm -12 $t/g $t/l | wc -l); pn=$(comm -13 $t/g $t/p | wc -l); ln=$(comm -13 $t/g $t/l | wc -l)
lost=$(comm -12 $t/g $t/p | comm -23 - <(comm -12 $t/g $t/l) | wc -l)
echo "$d golden=$(wc -l < $t/g) shared(pris)=$gp shared(law)=$gl notInGolden(pris)=$pn notInGolden(law)=$ln goldenLinesLost=$lost"
comm -12 $t/g $t/p | comm -23 - <(comm -12 $t/g $t/l) | head -${SHOW:-0}
rm -rf $t
