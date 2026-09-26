#!/bin/bash
c=$1; export GW=/tmp/v11u169_g2
p=$(/tmp/v11u169_grid.sh $c /tmp/v11u169_bin/pris P); l=$(/tmp/v11u169_grid.sh $c /tmp/v11u169_bin/law L); f=$(/tmp/v11u169_grid.sh $c /tmp/v11u169_bin/fix1 F)
rel=$(echo "$p" | awk '{print $1}'); w=$GW/$rel
t=$(python3 /tmp/v11u169_toward.py $w/gold/golden.uhdm $w/P.uhdm $w/F.uhdm 2>/dev/null | grep -o 'delta=[-0-9]* lostTowardGold=[0-9]*')
echo "$rel | P $(echo $p | awk '{print $3,$5,$6}') | L $(echo $l | awk '{print $3,$5,$6}') | F $(echo $f | awk '{print $3,$5,$6}') | P->F $t"
