#!/bin/bash
# order-blind dump diff: golden vs P, golden vs L, and the P->L changed lines
source /tmp/v11u144_env.sh
w=$(grep -lx "/tmp/v11u144_cases/$1" /tmp/v11u144_cw/*/dir | xargs dirname | head -1)
norm(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's/id:[0-9]+//g; s|/tmp/v11u144_cases/[^ ]*/||g' | sort; }
norm $w/golden.uhdm > $w/g.ob; norm $w/P.uhdm > $w/P.ob; norm $w/L.uhdm > $w/L.ob
gp=$(diff $w/g.ob $w/P.ob | grep -c '^[<>]'); gl=$(diff $w/g.ob $w/L.ob | grep -c '^[<>]')
echo "$1 golden-vs-P=$gp golden-vs-L=$gl"
[ -n "$SHOW" ] && diff $w/P.ob $w/L.ob | head -${SHOW}
true
