#!/bin/bash
# r11u417 show.sh <casedir> <binary> [ENV=VAL...]: golden vs ours dump diff for one case
c=$(readlink -f $1); B=$2; shift 2
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16)
tag=$(echo "$c $B $*" | md5sum | cut -c1-12)
diff /tmp/r11u417_gold/$h/golden.dump /tmp/r11u417_scr/o_$tag.uhdm.dump | grep -v 'Restored design\|^1c1\|^---$'
