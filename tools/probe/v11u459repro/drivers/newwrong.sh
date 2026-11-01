#!/bin/bash
# newwrong.sh <case dir> <tagA> <tagB>: diff lines against golden present for B but not for A (B's new disagreements)
D=$(dirname $0)
$D/dump.sh $1 gold > /tmp/v11u459_scr/n_g.txt
$D/dump.sh $1 $2 > /tmp/v11u459_scr/n_a.txt
$D/dump.sh $1 $3 > /tmp/v11u459_scr/n_b.txt
diff /tmp/v11u459_scr/n_g.txt /tmp/v11u459_scr/n_a.txt | grep '^[<>]' | sort > /tmp/v11u459_scr/n_da.txt
diff /tmp/v11u459_scr/n_g.txt /tmp/v11u459_scr/n_b.txt | grep '^[<>]' | sort > /tmp/v11u459_scr/n_db.txt
comm -13 /tmp/v11u459_scr/n_da.txt /tmp/v11u459_scr/n_db.txt
