#!/bin/bash
# dist.sh <case dir> <tagA> <tagB>: dump-diff line counts against golden (A, B)
D=$(dirname $0)
$D/dump.sh $1 gold > /tmp/v11u459_scr/d_g.txt
$D/dump.sh $1 $2 > /tmp/v11u459_scr/d_a.txt
$D/dump.sh $1 $3 > /tmp/v11u459_scr/d_b.txt
a=$(diff /tmp/v11u459_scr/d_g.txt /tmp/v11u459_scr/d_a.txt | grep -c '^[<>]')
b=$(diff /tmp/v11u459_scr/d_g.txt /tmp/v11u459_scr/d_b.txt | grep -c '^[<>]')
echo "$(echo $1 | sed 's|.*/cases/||') dist $2=$a $3=$b"
