#!/bin/bash
# newwrong.sh <casedir> <pristine> <law>: dump lines ours-only against golden that the law adds (multiset), i.e. candidate cells moving away
H=$(dirname $(readlink -f $0)); c=$(readlink -f $1)
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16); G=/tmp/v11u425_gold2/$h/golden.dump
d() { tag=$(echo "$c $1 " | md5sum | cut -c1-12); echo /tmp/v11u425_scr/o_$tag.uhdm.dump; }
P=$(d $2); L=$(d $3); [ -f $P ] && [ -f $L ] || { echo "run case.sh first"; exit 9; }
comm -13 <(diff $G $P | grep '^>' | sort) <(diff $G $L | grep '^>' | sort)
