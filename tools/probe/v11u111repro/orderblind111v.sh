#!/bin/bash
# order-blind dump diff: <dbA> <dbB> -> counts of lines only in A / only in B (ids and workdir stripped)
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
n(){ timeout 900 $D "$1" 2>/dev/null | sed -E 's/, id:[0-9]+//; s#/tmp/v11u111_wd_[a-z]{4}/##g' | sort; }
n "$1" > /tmp/v11u111_obA.$$; n "$2" > /tmp/v11u111_obB.$$
echo "A_only=$(comm -23 /tmp/v11u111_obA.$$ /tmp/v11u111_obB.$$ | wc -l) B_only=$(comm -13 /tmp/v11u111_obA.$$ /tmp/v11u111_obB.$$ | wc -l) sizeA=$(wc -l < /tmp/v11u111_obA.$$) sizeB=$(wc -l < /tmp/v11u111_obB.$$)"
comm -3 /tmp/v11u111_obA.$$ /tmp/v11u111_obB.$$ | head -${SHOW:-12}
rm -f /tmp/v11u111_obA.$$ /tmp/v11u111_obB.$$
