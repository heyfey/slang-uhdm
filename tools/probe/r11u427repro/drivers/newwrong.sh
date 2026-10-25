#!/bin/bash
# newwrong.sh <casedir> <pristine> <law>: dump lines the law writes that golden does not have and pristine did not write (multiset, '>' side of diff vs golden)
c=$(readlink -f $1); P=$2; L=$3
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16); G=/tmp/r11u427_gold/$h/golden.dump
for b in $P $L; do tag=$(echo "$c $b " | md5sum | cut -c1-12); diff <(sed 1d $G) <(sed 1d /tmp/r11u427_scr/o_$tag.uhdm.dump) | grep '^>' | sort > /tmp/r11u427_scr/nw_$(basename $b).txt; done
comm -13 /tmp/r11u427_scr/nw_$(basename $P).txt /tmp/r11u427_scr/nw_$(basename $L).txt
